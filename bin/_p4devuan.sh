# Nota: Su Devuan usiamo sysvinit o runit, systemctl potrebbe non funzionare. 
# Modifichiamo il riavvio della rete.
echo "Installazione strumenti di sviluppo Devuan..."
sudo apt-get update
sudo apt-get install -y build-essential golang dpkg-dev