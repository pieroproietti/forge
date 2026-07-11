#!/usr/bin/env bash
#
# pve-vnet.sh - crea/verifica/cancella vnet SDN su Proxmox VE (zona "simple"
# con DHCP dnsmasq + IPAM pve), parametrizzato via CLI.
#
# USO
#   pve-vnet.sh create  --vnet NOME --subnet CIDR [opzioni]
#   pve-vnet.sh status  --vnet NOME
#   pve-vnet.sh delete  --vnet NOME [--delete-zone]
#
# OPZIONI (create)
#   --vnet NAME           nome della vnet/bridge (obbligatorio)
#   --subnet CIDR         es. 10.99.0.0/24 (obbligatorio)
#   --zone NAME            default: uguale a --vnet
#   --gateway IP            default: primo IP utile della subnet
#   --dhcp-start IP         default: .100 della subnet
#   --dhcp-end IP           default: .250 della subnet
#   --no-snat               disabilita il masquerading verso l'esterno
#   --host MAC,IP,NOME       reservation DHCP con hostname (ripetibile)
#   --hosts-file FILE        file con righe "MAC,IP,NOME"
#   --ether MAC,IP           mapping statico senza hostname (ripetibile)
#   --ethers-file FILE        file con righe "MAC,IP"
#   --dry-run                 mostra solo i comandi, non esegue nulla
#
# OPZIONI (delete)
#   --vnet NAME            nome della vnet da rimuovere (obbligatorio)
#   --delete-zone           rimuove anche la zona (solo se resta vuota)
#   --dry-run
#
# OPZIONI (status)
#   --vnet NAME
#
set -euo pipefail

### ------------------------------ helper -----------------------------------

DRY_RUN=0
run() {
  echo "+ $*" >&2
  if [[ $DRY_RUN -eq 0 ]]; then "$@"; fi
}

die() { echo "Errore: $*" >&2; exit 1; }

usage() {
  sed -n '2,/^set -euo/p' "$0" | sed '$d;1d'
  exit 1
}

# calcola indirizzo IP = network + offset (offset intero, es. 1, 100, 250)
ip_offset() {
  local cidr="$1" offset="$2"
  python3 - "$cidr" "$offset" <<'PY'
import ipaddress, sys
net = ipaddress.ip_network(sys.argv[1], strict=False)
print(net.network_address + int(sys.argv[2]))
PY
}

require_pvesh() {
  command -v pvesh >/dev/null 2>&1 || die "pvesh non trovato: esegui questo script su un nodo Proxmox VE"
}

### --------------------------- parsing argomenti ----------------------------

[[ $# -ge 1 ]] || usage
CMD="$1"; shift || true

ZONE=""
VNET=""
SUBNET_CIDR=""
GATEWAY=""
DHCP_START=""
DHCP_END=""
SNAT=1
DELETE_ZONE=0
declare -a DHCP_HOSTS=()
declare -a ETHERS_HOSTS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vnet)          VNET="$2"; shift 2 ;;
    --zone)          ZONE="$2"; shift 2 ;;
    --subnet)        SUBNET_CIDR="$2"; shift 2 ;;
    --gateway)       GATEWAY="$2"; shift 2 ;;
    --dhcp-start)    DHCP_START="$2"; shift 2 ;;
    --dhcp-end)      DHCP_END="$2"; shift 2 ;;
    --no-snat)       SNAT=0; shift ;;
    --delete-zone)   DELETE_ZONE=1; shift ;;
    --host)          DHCP_HOSTS+=("$2"); shift 2 ;;
    --hosts-file)    while IFS= read -r l; do [[ -n "$l" && "$l" != \#* ]] && DHCP_HOSTS+=("$l"); done < "$2"; shift 2 ;;
    --ether)         ETHERS_HOSTS+=("$2"); shift 2 ;;
    --ethers-file)   while IFS= read -r l; do [[ -n "$l" && "$l" != \#* ]] && ETHERS_HOSTS+=("$l"); done < "$2"; shift 2 ;;
    --dry-run)       DRY_RUN=1; shift ;;
    -h|--help)       usage ;;
    *) die "opzione sconosciuta: $1" ;;
  esac
done

[[ -n "$VNET" ]] || die "--vnet è obbligatorio"
ZONE="${ZONE:-$VNET}"
DNSMASQ_DIR="/etc/dnsmasq.d/${ZONE}"

require_pvesh

### -------------------------------- create -----------------------------------

cmd_create() {
  [[ -n "$SUBNET_CIDR" ]] || die "--subnet è obbligatorio per create"

  GATEWAY="${GATEWAY:-$(ip_offset "$SUBNET_CIDR" 1)}"
  DHCP_START="${DHCP_START:-$(ip_offset "$SUBNET_CIDR" 100)}"
  DHCP_END="${DHCP_END:-$(ip_offset "$SUBNET_CIDR" 250)}"
  SUBNET_ID="${ZONE}-${SUBNET_CIDR//\//-}"

  if [[ $DRY_RUN -eq 0 ]] && ! dpkg -s dnsmasq >/dev/null 2>&1; then
    apt update && apt install -y dnsmasq
  fi
  run systemctl disable --now dnsmasq || true

  echo "=== Zona '${ZONE}' ==="
  if [[ $DRY_RUN -eq 1 ]] || ! pvesh get "/cluster/sdn/zones/${ZONE}" >/dev/null 2>&1; then
    run pvesh create /cluster/sdn/zones --zone "${ZONE}" --type simple --dhcp dnsmasq --ipam pve
  else
    echo "  già esistente, salto"
  fi

  echo "=== Vnet '${VNET}' ==="
  if [[ $DRY_RUN -eq 1 ]] || ! pvesh get "/cluster/sdn/vnets/${VNET}" >/dev/null 2>&1; then
    run pvesh create /cluster/sdn/vnets --vnet "${VNET}" --zone "${ZONE}"
  else
    echo "  già esistente, salto"
  fi

  echo "=== Subnet ${SUBNET_CIDR} (gw ${GATEWAY}, dhcp ${DHCP_START}-${DHCP_END}) ==="
  SUBNET_ARGS=(--subnet "${SUBNET_CIDR}" --type subnet --gateway "${GATEWAY}"
               --dhcp-range "start-address=${DHCP_START},end-address=${DHCP_END}")
  [[ $SNAT -eq 1 ]] && SUBNET_ARGS+=(--snat 1)

  if [[ $DRY_RUN -eq 1 ]] || ! pvesh get "/cluster/sdn/vnets/${VNET}/subnets/${SUBNET_ID}" >/dev/null 2>&1; then
    run pvesh create "/cluster/sdn/vnets/${VNET}/subnets" "${SUBNET_ARGS[@]}"
  else
    echo "  già esistente, salto"
  fi

  echo "=== Applico configurazione SDN ==="
  run pvesh set /cluster/sdn

  echo "=== File custom in ${DNSMASQ_DIR} (20-hosts.conf, ethers) ==="
  if [[ $DRY_RUN -eq 0 && ( ${#DHCP_HOSTS[@]} -gt 0 || ${#ETHERS_HOSTS[@]} -gt 0 ) ]]; then
    mkdir -p "${DNSMASQ_DIR}"
    if [[ ${#DHCP_HOSTS[@]} -gt 0 ]]; then
      {
        echo "# generato da pve-vnet.sh - non gestito da SDN"
        for entry in "${DHCP_HOSTS[@]}"; do
          IFS=',' read -r mac ip host <<< "${entry}"
          echo "dhcp-host=${mac},${ip},${host}"
        done
      } > "${DNSMASQ_DIR}/20-hosts.conf"
    fi
    if [[ ${#ETHERS_HOSTS[@]} -gt 0 ]]; then
      : > "${DNSMASQ_DIR}/ethers"
      for entry in "${ETHERS_HOSTS[@]}"; do
        IFS=',' read -r mac ip <<< "${entry}"
        echo "${mac},${ip}" >> "${DNSMASQ_DIR}/ethers"
      done
    fi
    run systemctl restart "dnsmasq@${ZONE}"
  else
    echo "  nessun --host/--ether passato, salto"
  fi

  echo "OK: vnet '${VNET}' (zona '${ZONE}') creata su ${SUBNET_CIDR}"
}

### -------------------------------- status -----------------------------------

cmd_status() {
  echo "=== Zona ==="
  pvesh get "/cluster/sdn/zones/${ZONE}" --output-format json 2>/dev/null \
    || echo "  zona '${ZONE}' non trovata"
  echo "=== Vnet ==="
  pvesh get "/cluster/sdn/vnets/${VNET}" --output-format json 2>/dev/null \
    || echo "  vnet '${VNET}' non trovata"
  echo "=== Subnet ==="
  pvesh get "/cluster/sdn/vnets/${VNET}/subnets" --output-format json 2>/dev/null \
    || echo "  nessuna subnet"
  echo "=== Servizio dnsmasq@${ZONE} ==="
  systemctl status "dnsmasq@${ZONE}" --no-pager -l 2>/dev/null || echo "  servizio non attivo"
  echo "=== Interfaccia di rete ==="
  ip -br link show "${VNET}" 2>/dev/null || echo "  interfaccia '${VNET}' non trovata"
  echo "=== Lease attivi ==="
  cat "/var/lib/misc/dnsmasq.${ZONE}.leases" 2>/dev/null || echo "  nessun file di lease"
}

### -------------------------------- delete -----------------------------------

cmd_delete() {
  echo "=== Rimuovo subnet di '${VNET}' ==="
  # elenca gli id delle subnet della vnet e le cancella tutte
  if [[ $DRY_RUN -eq 0 ]]; then
    ids=$(pvesh get "/cluster/sdn/vnets/${VNET}/subnets" --output-format json 2>/dev/null \
          | python3 -c 'import json,sys; print("\n".join(s["subnet"] for s in json.load(sys.stdin)))' 2>/dev/null || true)
    for id in $ids; do
      run pvesh delete "/cluster/sdn/vnets/${VNET}/subnets/${id}"
    done
  else
    echo "+ (dry-run) pvesh delete /cluster/sdn/vnets/${VNET}/subnets/<ogni-subnet>"
  fi

  echo "=== Rimuovo vnet '${VNET}' ==="
  run pvesh delete "/cluster/sdn/vnets/${VNET}" || true

  if [[ $DELETE_ZONE -eq 1 ]]; then
    echo "=== Rimuovo zona '${ZONE}' (se vuota) ==="
    run pvesh delete "/cluster/sdn/zones/${ZONE}" || true
  fi

  echo "=== Applico configurazione SDN ==="
  run pvesh set /cluster/sdn

  echo "=== Pulizia file custom in ${DNSMASQ_DIR} ==="
  if [[ $DRY_RUN -eq 0 && -d "${DNSMASQ_DIR}" ]]; then
    run rm -f "${DNSMASQ_DIR}/20-hosts.conf" "${DNSMASQ_DIR}/ethers"
    # rimuove la dir solo se è rimasta vuota (zona cancellata)
    rmdir "${DNSMASQ_DIR}" 2>/dev/null || true
  fi

  echo "OK: vnet '${VNET}' rimossa"
}

### -------------------------------- dispatch ----------------------------------

case "$CMD" in
  create) cmd_create ;;
  status) cmd_status ;;
  delete) cmd_delete ;;
  *) usage ;;
esac
