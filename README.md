# forge

E' il mio raccoglitore di progetti, ne ho sentito la necessità per uniformare il repository penguins-blog [panguins-eggs.net](https://panguins-eggs.net) con oa-tools e penguins-eggs.

Visto che sto sperimentando claude, ed il suo agent, riporto le istruzioni per l'installazione di nodejs via npm senza problemi di sudo:

Aprire terminale:
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
```
Uscire e riaprire il teminale:
```
nvm install --lts
npm install -g @anthropic-ai/claude-code
npm install -g pnpm
cd penguins-eggs 
npm i
```
