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
