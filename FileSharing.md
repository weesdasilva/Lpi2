# **209 Compartilhamento de Arquivos.**

## 209.1 - Configurações do servidor Samba

O Samba fornece serviços de arquivo e impressão seguros, estáveis ​​e rápidos para todos os clientes que usam o protocolo SMB / CIFS usados para no windows.

Também é possível integrar o samba com o servidor de controle do windows (PDC).

Confira: [Site e Documentação](https://www.samba.org)

### Pacotes:
* **samba** - Servidor
* **samba-client** - Ferramentas de gerenciamento.

Obs: Em Ambas as distribuições (Debian e Centos) o pacote do samba tem o mesmo nome.

### Processos:

**smbd** - Responsável por fornecer os compartilhamentos em si de arquivos e impressoras.

**Portas:**
* 139/tcp - Serviço de sessão NetBios
* 445/tcp - Active Directory, Windows shares

**nmbd** - Trabalha com o NetBios para resolução de nome no Windão.

**Portas:**
* 137/udp - NetBIOS Name Service
* 138/udp - Serviço de datagrama NetBios roteamento de pacotes.

### Arquivos de configuração:

 A maioria das configurações do samba são feitas no arquivo **/etc/samba/smb.conf**

```bash
[global]
        workgroup = SAMBA
        security = user

        log file = log file = /var/log/samba/log.%m
        unix password sync = yes

        passdb backend = tdbsam

        printing = cups
        printcap name = cups
        load printers = yes
        cups options = raw



[printers]
        comment = All Printers
        path = /var/tmp
        printable = Yes
        create mask = 0600
        browseable = No

[print$]
        comment = Printer Drivers
        path = /var/lib/samba/drivers
        write list = @printadmin root
        force group = @printadmin
        create mask = 0664
        directory mask = 0775
```

* **[global]** - Configurações gerais do servidor samba.
* **workgroup** - Nome do grupo de trabalho para integração com o AD.
* **log file** - Onde sera armazenado os logs do samba.
* **unix password sync** - Sincroniza a senha do samba com o sistema unix.

### Compartilhando Files

```bash
[homes]
        comment = Home Directories
        read only = yes
        ##writeable = no
        browseable = No
        create mask = 0700
        directory mask = 0700
        valid users = %S
        guest ok = yes

```
* **[home]** Abertura do bloco de compartilhamento. Obs: se inserido um **$** o compartilhamento ficara oculto no windows.
* **Comment**     - Descrição que será apresentada para o cliente.
* **browseable**  - Define se o compartilhamento será exibido ou não na listagem padrão.
* **read only**   - Declara se o compartilhamento será somente leitura.
* **writeable**   - Declara se o compartilhamento terá permissão de gravação (Obs: Essa opção deve estar ausente na presença do parâmetro **read only**).
* **create mask = 0700** - Declara uma mascara para a criação de arquivos
* **directory mask = 0700** - Idem porém para diretórios
* **valid users** - usuários que poderão se autenticar no diretório  compartilhado **%S** apenas o dono do compartilhamento, para definir algum usuario especifico basta passar o nome do usuario ex: valid users = weslley .
* **guest ok** - Se yes usuario anonimos conseguiram acessar o compartilamento.


## Compartilhando impressoras

```bash
[printers]
   comment = All Printers
   browseable = yes
   path = /var/spool/samba
   printable = yes
   guest ok = no
   read only = yes
   create mask = 0700
```

* **path** - em compartilhamento de impressora o path será um intermediador do samba para a impressora .
* **printable** - Parâmetro que define que esse compartilhamento e uma impressora.

Uma boa pratica e compartilhar os drivers da impressora junto com o samba.

```bash
[print$]
   comment = Printer Drivers
   path = /var/lib/samba/printers
   browseable = yes
   read only = yes
   guest ok = no
```

## Comandos de gerenciamento:

**smbpasswd**

Nos permite definir ou alterar a senha de um usuario para o samba.

* -a - Adicionara um usuário no sistema.
* -d - desabilitara um usuário
* -e - habilitara um Usuário
* -n - cria um usuário sem senha
* -x - deleta um usuário.

```bash
smbpasswd -a weslley
New SMB password:
Retype new SMB password:
Added user weslley.
```

**pdbedit**

Binário que nós possibilita gerenciar a base de dados de usuários geradas pelo samba.

* **-L** - Lista todos os usuários.
* **-u** - Lista apenas um usuário.
* **-v** - Exibe mais informações na listagem do usuário.

```bash
pdbedit -L
weslley:1001:
```

**testparm**

Checa se existe algum erro no arquivo smb.confiar

* **-v** - Com esse parametro será apresentado todos os parâmetros default aplicados no arquivo.

**smbclient**

Binário que realiza a conexão a um servidor samba.

```bash
smbclient //10.10.0.2/weslley -U weslley
```
* **-L** - Exibe apenas os compartilhamentos de um cliente.
* **-U** - Usuário de conexão.

**smbstatus**

Exibe o status de conexões do samba.

* **-S** - Exibe os compartilhamentos
* **-p** - pid do compartilhamento

### Montando compartilhamento

Para montar um compartilhamento samba é necessario ter em seu cliente Linux o pacote **cifs-utils** que irá trazer uma suite de pacotes do cifs protocolo que o windows usa para compartilhar os arquivos.

```bash
mount -t cifs -o username=weslley,password=4linux //10.10.0.2/weslley /mnt
```

* **mount** - binário que realiza montagem de diretórios locais e remotos com diversos filesystem.
* **-o** - parametro de opções que possibilita passar um **username** e **password** na hora da montagem.

Para montar no fstab também é simples, basta adicionar:

```bash
//10.10.0.2/weslley      /mnt cifs  user,username=weslley,password=4linux 0 0

```

Ou

```bash
//10.10.0.2/weslley      /mnt cifs     user,credentials=/root/acesso 0 0
```
* **credentials** - Essa opção nos permite passar usuario e senha na montagem, basta colocar o usuario em texto plano ou passar um arquivo com asa seguintes entradas:

```
username=weslley
password=4linux
```
