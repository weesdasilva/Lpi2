**2CompartilhamenArquivos.**

209.1 - Configurações do servidor Samba

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

**Username Maps**

Esse é um recurso muito interessante do samba que nos permite mapear um nome para uma conta criada.

Adicione no **/etc/samba/smb.conf** a seguinte linha:

```bash
username map = path_file
```

Conteúdo do arquivo:
```
batata = weslley
Weslley = weslley
```

* **account = alias** - O primeiro parâmetro e o nome da conta criada seguida do alias desejado, no exemplo acima demos o apelido **batata** para a conta **weslley**.

### Security no samba.

Exitem alguns modos de segunça no samba que irão alterar a sa forma de funcionamento.

Para habilitar algum basta dentro do arquivo de configuração do samba adicionar o seguinte bloco:

```bash
security = modesecurity
```

* **user** - Basicamente é o modo padrão que exige credencias de autenticação para ter acesso aos compaprtilhamentos

* **domain** - O samba vira um membro de um dominio onde toda a autenticação e redirecionada para um AD. obs: esse mode faz par com o parâmetro **("workgroup = BATATAS")**.

* **ADS (Active Directory Security Mode)** - O samba fará parte de algum AD   

Sintax do ADS:

```bash
[GLOBAL]
...
security = ADS
realm = EXAMPLE.COM
password server = kerberos.example.com  
```

Referência dos modes: [Aqui](https://web.mit.edu/rhel-doc/5/RHEL-5-manual/Deployment_Guide-en-US/s1-samba-security-modes.html)

### Ingressando samba no AD.

Para ingressar o samba no AD é necessário ter instalado os seguintes pacotes:
* **winbind** - Esse pacote fornece o winbindd, um daemon que integra autenticação e mecanismos de serviços de diretório (busca por usuário e grupo) de um domínio Windows em um sistema Linux
* **libnss-winbind** - Pacote que irá fornecer buscas de nomes de usuarios/grupos pelo samba através do nsswitch.conf.
* **libpam-winbind** - A autenticação de domínio Windows baseada no Windbind pode ser ativada através deste pacote.
* **krb5-config**  - Pacote que irá trazer o kerberos 5 que é um protocolo de autenticação.

Edite o **/etc/samba/smb.conf** e indique o servidor que o o samba fara parte

```bash
[GLOBAL]
   security = ads
   workgroup = WEESDASILVA
   realm = weesdasilva.ops
   netbios name = server-samba

```

* **security** - ads - então esse samba irá ingressar em um dominioexemplo
* **workgroup** - Grupo de trabalho do AD.
* **realm** - Nome do dominio que o samba fara parte.
* **netbios name** - Nome que o samba será apresentado na rede NETBIOS.



Para que o servidor faça parte do AD o mesmo tem que usar o DNS do windão server. Edite o **/etc/resolv.conf** e adicione a seguinte entrada:

```bash
nameserver 10.10.0.5 # IP do Windows Server
```

Também é necessário adicionar a criação da home sempre quando algum usuario fizer login em sua maquina. Edite o **/etc/pam.d/common-session** e adicione a seguinte entrada

```bash
session optional        pam_mkhomedir.so skel=/etc/skel umask=077
```

**net** - Ferramenta para administração de servidores sambas, com ele e pososivel conectar uma maquina em algum realm e ate mesmo verificar o status dessa conexão.

Usando o net vamos forcar um join em um dominio AD. Execute o seguinte comando:

```bash
net ads join -U administrator
```
* **ads** - Executar funções usando transporte ADS
* **join** - Conexão uma maquina local ao realm configurado no arquivo do samba.
* **-U** - Usuário administrador.

também conseguimos realizar vários tipos de verificação:

**net -S nome-AD time** - com isso estamos pegando a hora do servidor que hospeda o AD.
**net -S localhost -U weslley share** - Aqui verificamos os compartilhamentos de um usuario.

Agora basta reiniciar os serviços do samba para que o mesmo passe a funcionar.

```bash
for service in winbind smbd nmbd
do  
systemctl restart ${service}
done
```

Para testar a conexão execute:

```bash
wbinfo --ping-dc
#Output
checking the NETLOGON for domain[WEESDASILVA] dc connection to "WIN-QSKQ7OF48DN.weesdasilva.ops" succeeded
```
[Referencia Aqui](https://www.server-world.info/en/note?os=Debian_9&p=samba&f=3)

#### Verificando usuários criados no ad.

Após a ingressão do samba em um PDC o mesmo ja tem acesso a todas informações que existem no AD principal, vamos filtralas...

**wbinfo** - Consultar informações do daemon winbind

Para verificar todos os usuarios que existem no AD execute:

```bash
wbinfo -u
```
* **-u** - Lista todas as contas de usuarios.
* **-g** - Lista todas os grupos.

#### Comandos extras:

**nmblookup** - Binario usario para consultar nomes de maquinas pelo NetBIOS
* **-S** - Exibe por nome alem do IP o status de uma maquina no NetBios.

```bash
nmblookup -S server-samba

##Output
10.10.0.2 server-samba<00>
Looking up status of 10.10.0.2
	SERVER-SAMBA    <00> -         B <ACTIVE>
	SERVER-SAMBA    <03> -         B <ACTIVE>
	SERVER-SAMBA    <20> -         B <ACTIVE>
	..__MSBROWSE__. <01> - <GROUP> B <ACTIVE>

```
* **-A** - Trás o memso status porém pelo endereço de IP

```bash
nmblookup -A 10.10.0.5

#Output
Looking up status of 10.10.0.5
	WIN-QSKQ7OF48DN <00> -         B <ACTIVE>
	WEESDASILVA     <1c> - <GROUP> B <ACTIVE>
	WEESDASILVA     <00> - <GROUP> B <ACTIVE>

```

**samba-tool** - Ferramenta de gerenciamento do samba quando o mesmo se torna um AD.

* **processes** - Lista os processos responsavel por manter o serviço no ar.
* **user**  - lista os usuarios
* **domain** - lista o dominio que o samba faz parte.

```bash
samba-tool domain info 10.10.0.5

#Output
Forest           : weesdasilva.ops
Domain           : weesdasilva.ops
Netbios domain   : WEESDASILVA
DC name          : WIN-QSKQ7OF48DN.weesdasilva.ops
DC netbios name  : WIN-QSKQ7OF48DN
```

**smbcontrol** - Gerencia os processos do samba.

```bash
smbcontrol smbd reload-config  # Recarega as configuraçõs do smbd
smbcontrol winbind reload-config # Recarrega as configurações do winbind
smbcontrol all reload-config     # recarrega as configurações de todos os serviços  
smbcontrol nmbd shutdown         # Desligamento do nmbd

```

## 209.2 - Configuração do servidor NFS

Nfs (Network File System) - É um procotolo que posibilita compartilhar arquivos e diretórios dentro de uma rede de computadores.

Pacotes:

**Debian:**

* **rpcbind** -  Pacote usado pelo nfs3 para #######################################################################
* **nfs-kernel-server** - Pacote que irá criar um servidor NFS.
* **nfs-common** - Ferramentas de montagem NFS.

**Centos:**
* **nfs-utils** - Pacote que irá criar um servidor NFS e trará as ferramentas de montagem NFS.
* **rpcbind** Pacote usado pelo NFS3 que irá tornar possivél a montagem .

### Processos:

**rpcbind "portmap"** - Responsável por mapear as portas que os clientes irão utilizar para realizar as montagem
* **Porta:** 111

**mountd "rpc.mountd"** - Daemon responsável por gerar portas dinâmicas que irão efetivamente realizar as montagem nos clientes.

### Criando compartilhamento.

O compartilhamento de um diretório será feito atráves do arquivo **/etc/exports**.

sintax:

```bash
Caminho-Pasta Endereço-rede(Parâmetros-Compartilhamento)
```

O primeiro parametro faz referencia a pasta que você deseja compartilhas ;

Seguido do endereço de ip ou rede que poderá montar esse compartilhamento ex: 10.10.0.2 ou 10.10.0.0/24 ;

Após o endereço é onde colocamos diversos parâmetros para o funcionamento do compartilhamento, abaixo segue as principais opções:
* **rw** - Habilita a leitura e escrita dentro do compartilhamento
* **ro** - Apenas leitura
* **sync** - Responda às solicitações somente depois que as alterações forem confirmadas no armazenamento estável.
* **async** Diferente do sync essa opção retornará para o cliente uma resposta imediata, independente se o disco efetivou a gravação no disco com isso ganhamos performasse porém os arquivos podem ser corrompidos.
* **no_subtree_check** Montagem em uma partição que não foi completamente ocmpartilhada. ###########################
* **root_squash** - Quando um usuário root acessa o compartilhamento o nfs irá tornar esse usuário anonimo.
* **no_root_squash** - Com isso o usuário terá permissão de root no compartilhamento.
* **all_squash** - Essa opção e para usuarios onde o nfs torna todo o acesso para um usuario anonimo.
* **no_all_squash** - Opção padrão que mantém os uid e gid dos usuários durante a conexão.


### Comandos de gerenciamento

**exportfs** - Binário que efetiva o compartilhamento dos diretórios descritos dentro de **/etc/exports**. obs: Quando o compartilhamento e efetivado o binário replica as informações dentro do **/var/lib/nfs/etab**, arquivo parecido com o **fstab** que será reponsavel por disponibilizar o compartilhamento no momento do boot.
* Sem parametro o exportfs mostra todos os compartilhamentos.
* **-a** - Exporte ou não exporte todos os diretórios.
* **-v** - Mostra os compartilhamentos com todos os parâmetros habilitados.
* **-r** - Reexporta os compartilhamentos.
* **-au** - Unexport todos os compartilhamentos.

O exportfs também nos possibilita montar um compartilhamento temporário:

```bash
exportfs 10.10.0.1:/etc -o rw,sync,no_root_squash
```
* O primeiro parametro e passar com quem será feito o compartilhamento seguido pelo diretorio a ser compartilhado separado por um ":".
* Depois com o **-o** e passado os parametros de compartilhamento

**showmount** - Mostra os compartilhamentos disponíveis do NFS.
* **-e** - Mostra a lista de exportação do nfs. também é possível mostrar os compartilhamentos disponíveis para um IP tanto cliente qanto servidor.
```
showmount -e 10.10.0.2
```
* **-d** - Listar apenas os diretórios montados por algum cliente.


**nfsstat** - Lista as estatisticas de um servidor NFS.
* **-s** - mostra as estatísticas do SERVER
* **-c**  - mostra as estatísticas do CLIENTE

###Pontos importantes:

O NFS usa um pseudo Filesystem, então sempre quando a uma montagem do / do compartilhamento será apresentado apenas os compartilhamentos disponíveis para o cliente.

```bash
mount.nfs 10.10.0.2:/ /opt/

##Output
home  opt  var
```

Para alterar o pseudo o filesystem padrão basta incluir em algum compartilhamemnto o parametro:
* **fsid=0**

Assim esse compartilhamento passara a ser a raiz com compartilhamento.

### TcpWappers

É possível integrar o NFS com as ACLS do sistema, Para bloquear a montagem dos compartilhamentos adicione no arquivo **/etc/hosts.deny**:

```bash
rpc.mountd: 10.10.0
```
* O primeiro parâmetro faz referencia ao nome do serviço.
* Já o segundo se refere a uma rede ou endereço especifico.

Para bloquear a listagem dos compartilhamentos adicione no mesmo arquivo:

```bash
rpcbind: 10.10.0.
```
* Assim a exibição dos compartilhamentos serão bloqueadas Obs: A montagem ainda poderá ser feita caso apenas essa linha esteja presente.
