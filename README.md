# arch-post-install

Automação de pós-instalação para uma estação Arch Linux com GNOME mínimo.

O objetivo é partir de uma instalação básica feita pelo `archinstall` e configurar, após o primeiro login do usuário, apenas os componentes necessários do desktop. Aplicativos utilitários serão preferencialmente instalados como Flatpak, evitando o grupo completo `gnome`.

## Premissas

Antes de executar:

- Arch Linux já instalado e inicializando normalmente;
- usuário comum criado;
- usuário com acesso a `sudo`;
- conexão com a internet funcionando;
- driver gráfico definido durante a instalação inicial;
- Secure Boot e criptografia não são configurados por este projeto.

## Conectividade inicial

Para clonar este repositório é necessário que o Arch tenha acesso à internet. Se houver um cabo de rede conectado e a rede tiver DHCP, normalmente nenhuma configuração adicional é necessária.

### Conectar ao Wi-Fi no ambiente live do Arch

A documentação oficial do Arch recomenda usar o `iwctl`, fornecido pelo `iwd`, para autenticar em redes Wi-Fi no ambiente da mídia de instalação.

Primeiro, confirme que a interface de rede sem fio existe:

```bash
ip link
```

Se necessário, confirme também que o Wi-Fi não está bloqueado:

```bash
rfkill
```

Abra o `iwctl`:

```bash
iwctl
```

No prompt `[iwd]#`, liste os dispositivos Wi-Fi:

```text
device list
```

Identifique o dispositivo sem fio, por exemplo `wlan0`, `wlp2s0` ou nome semelhante. Em seguida, procure redes disponíveis:

```text
station DISPOSITIVO scan
station DISPOSITIVO get-networks
```

Conecte à rede desejada:

```text
station DISPOSITIVO connect "NOME-DO-WIFI"
```

Exemplo:

```text
station wlan0 connect "Minha Rede"
```

Se a rede exigir senha, o `iwctl` solicitará a senha interativamente. Para SSIDs com espaços, mantenha o nome entre aspas.

Saia do `iwctl` com `Ctrl+D` e teste a conexão:

```bash
ping -c 3 ping.archlinux.org
```

Se houver resposta, a conexão está funcionando.

> Na ISO oficial do Arch, `iwd`, `systemd-networkd` e `systemd-resolved` já vêm preparados para uso no ambiente live. Isso não significa que o sistema instalado usará `iwd`: neste projeto, a rede permanente deve ser configurada no `archinstall`, preferencialmente com NetworkManager.

Referências oficiais:

- ArchWiki — Installation guide: https://wiki.archlinux.org/title/Installation_guide
- ArchWiki — iwd: https://wiki.archlinux.org/title/Iwd

### Alternativa: internet do celular por USB

Também é possível usar o compartilhamento de internet do celular por USB (USB tethering). Em muitos aparelhos Android, basta conectar o celular por USB e ativar **Compartilhamento de internet via USB** nas configurações do aparelho. O Linux normalmente detecta a interface de rede criada pelo telefone e obtém endereço IP por DHCP.

Depois de ativar o compartilhamento, confirme a nova interface:

```bash
ip link
```

E teste a conexão:

```bash
ping -c 3 ping.archlinux.org
```

Esse método pode ser útil quando não há Ethernet disponível e a configuração do Wi-Fi não é conveniente.

## Pré-requisito: Git

O pacote `base` do Arch Linux **não inclui o Git**. Dependendo das opções escolhidas no `archinstall`, ele pode já estar disponível, mas este projeto não assume isso.

Após o primeiro login, verifique:

```bash
git --version
```

Se o comando não existir, instale o Git antes de clonar este repositório:

```bash
sudo pacman -S git
```

Depois siga normalmente com o clone.

## GNOME instalado

O script instala somente a base funcional escolhida para esta máquina:

- GNOME Shell;
- GNOME Session;
- GDM;
- GNOME Settings (`gnome-control-center`);
- Nautilus;
- GNOME Console;
- GNOME Software;
- GNOME Keyring;
- portal do GNOME para integração com Flatpak;
- Power Profiles Daemon;
- Switcheroo Control para integração com sistemas de GPU híbrida.

Não são instalados pelo `pacman` aplicativos como Calculadora, Calendário, navegador, editor de texto, mapas, clima ou outros utilitários GNOME.

## Uso

Após entrar no usuário da instalação básica:

```bash
git --version || sudo pacman -S git
git clone https://github.com/rafatosta/arch-post-install.git
cd arch-post-install
bash install.sh
```

Ao final, reinicie:

```bash
reboot
```

O GDM deverá iniciar e disponibilizar a sessão GNOME.

## O que o instalador faz

1. atualiza o Arch com `pacman -Syu`;
2. instala somente os componentes adicionais necessários ao pós-instalação;
3. instala o GNOME mínimo;
4. habilita o GDM;
5. instala Flatpak e configura Flathub;
6. executa verificações básicas;
7. detecta a presença de NVIDIA, mas não altera o driver.

Rede, áudio, usuário/root, kernel, bootloader e driver gráfico devem ser definidos previamente no `archinstall`.

## Estrutura

```text
.
├── install.sh
├── scripts/
│   ├── 01-system.sh
│   ├── 02-gnome.sh
│   └── 03-flatpak.sh
├── checks/
│   └── verify.sh
└── README.md
```

## NVIDIA

A instalação do driver NVIDIA fica deliberadamente fora do pós-instalação. O driver deve ser selecionado/configurado no fluxo inicial do Arch/`archinstall`.

A verificação final apenas detecta uma GPU NVIDIA e informa se `nvidia-smi` está disponível. Isso permite usar o mesmo repositório em máquina virtual e na estação física sem instalar um driver inadequado automaticamente.

## Próximas etapas

O repositório está preparado para receber módulos separados para:

- aplicativos Flatpak;
- AUR e helper (`yay`/`paru`);
- ferramentas de desenvolvimento;
- VS Code;
- configurações pessoais do GNOME;
- verificações específicas da NVIDIA/Wayland;
- perfil de VM e perfil da estação física.
