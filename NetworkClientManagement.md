# Tópico 210 - Administração dos clientes de rede.

## 210.1 Configuração do DHCP.

DHCP (Dynamic Host Configuration Protocol) é um protocolo que disponibiliza um endereço de IP a um cliente de forma automática em uma rede.

### Pacotes:

***Debian:***
* **isc-dhcp-server**

***Centos:***
* **dhcp**

#### Processos:
* **dhcpd** - Processo do dhcp.


### Portas:

* **67** - Porta que o DHCP escuta requisições.
* **68** - Porta de resposta.

#### Arquivos:

***Debian:***

Para alterar o funcionamento do pacote o debian conta com alguns arquivos:

**/etc/default/isc-dhcp-server** - Dentro desse arquivo é possível alterar os parametros de inicialização do processo.
* **INTERFACESv4="eth1"** - define qual a interface que o serviço ira rodar
* **DHCPDv4_CONF=/etc/dhcp/dhcpd.conf** - configura qual é o principal arquivo de confguração.

**/etc/dhcp/dhcpd.conf** - Aqui editamos os parâmetros para a aplicação.

* **option domain-name "weesdasilva.ops";** - Define qual será o dominio fornecido para os clientes.
* **option domain-name-servers 1.1.1.1 8.8.8.8;** - Define qual e os servidores de DNS que o server irá distribuir.
* **default-lease-time 600;** - Verifica de 600 em 600 segundos se um ip fornecido ainda está em uso.
* **max-lease-time 7200;** - Tempo máximo que o cliente poderá ficar com o mesmo ip.
* **authoritative;** - Define se esse servidor será um server authoritative em sua rede.

* **subnet 10.10.0.0 netmask 255.255.255.0 { }** - Bloco que define qual rede o servidor irá trabalhar obs: para limitar um range e definir um gatway padrão basta declarar dentro do bloco.
```
subnet 10.10.0.0 netmask 255.255.255.0 {
    range 10.0.0.100 10.10.0.200;
    option routers 10.10.2.15;
}
```

### Comandos de gerenciamento.

#### **dhclient** - Binário usado para solicitar um endereço para um servidor dhcp.

* **-r** - libera um endereço fornecido por um servidor dhcp

**Fluxo grama de comunicação.**

```
bash ~# dhclient

###Output
DHCPDISCOVER from 08:00:27:b8:cc:48 via eth1
DHCPOFFER on 10.10.0.6 to 08:00:27:b8:cc:48 via eth1
DHCPREQUEST for 10.10.0.6 (10.10.0.2) from 08:00:27:b8:cc:48 via eth1
DHCPACK on 10.10.0.6 to 08:00:27:b8:cc:48 via eth1
```

* **DHCPDISCOVER** - É a informação que uma maquian está procurando por um servidor de dhcp via BROADCAST
* **DHCPOFFER** - É a oferta do nosso servidor DHCP oferecendo um endereço neste caso o **10.10.0.6**
* **DHCPREQUEST** - Resposta do cliente solicitando o endereço oferecido.
* **DHCPACK**  - fechamento de comunicação ACK.

```
dhclient -r

##Output
DHCPRELEASE of 10.10.0.6 from 08:00:27:b8:cc:48 via eth1 (found)
```
* **DHCPRELEASE** - Servidor cliente liberando um endereço.

**Quando o nosso servidor fornece um endereço como forma de controle ele armazena essas informações dentro de /var/lib/dhcp/dhcpd.leases.**

```
lease 10.10.0.5 {
  starts 6 2020/02/15 23:03:33;
  ends 6 2020/02/15 23:13:33;
  cltt 6 2020/02/15 23:03:33;
  binding state active;
  next binding state free;
  rewind binding state free;
  hardware ethernet 0a:00:27:00:00:03;
  client-hostname "debian";
}
```

* **starts** - Quando foi feito a verificação.
* **ends** - Até quando ela será valida obs: de 10 em 10 minutos o servidor irá verificar o endereço.

**Para definir um endereço fixo a um cliente basta realizar a criação de um novo bloco no arquivo de configuração.**

```
host maquina {
  hardware ethernet MEC-PLACA;
  fixed-address 10.10.0.50;
}
```

* **host** - Seleciona uma maquina por nome.
* **hardare ethernet** - Seleciona uma maquina por endereço mec.
* **fixed-address** - fixa um endereço para um cliente.

Conseguimos também limitar a distribuição de um ip a hosts que apenas estejam mapeados pela opção ***hosts***, adicione no arquivo de configuração:

```
deny unknow-clients;
```

### Bootp

O BOOTP pode ser chamado de antecessor do DHCP, onde esse protocolo era usado para obter um endereço de forma automática em uma rede. o mesmo tambem era usado para formatar uma maquina assim que ela entra em uma rede.

Exemplo de configuração:

```bash
allow botting;
allow bootp;

host maquina-semdisco {
  hardware ethernet MEC-PLACA;
  fixed-address IP-Fixo;
  filename "/vmlinux.exemolo"
  server-name "10.10.0.2"
}
```

* **filename** - Indica a imagem que será baixada pelo cliente.
* **server-name** - Indica aonde o cliente irá baixar a imagem.

### DHCP Relay

 Parecido com um proxy é a forma de redirecionar toda a solicitação de endereço para um servidor primário de DHCP.

#### Pacote:
 * **isc-dhcprelay**

#### Comando de inicialização:

```bash
dhcrelay -i enp0s3 10.10.0.1
```
* **-i** - indica a interface que o relay irá funcionar seguido do ip do DHCP principal.

Obs: Também é possivel definir isso de forma permanente denntro de **/etc/default/isc-dhcp-relay**.

### NDP (Neighbor Discovevery Protocol)

Protocolo que possibilita que um cliente IPV6 se alto configure.

Obs: Esse protocolo e instalado através do pacote radvd.

## PAM (Pluggable Authentication Modules)

O pam fornece uma interface de autenticação para que aplicações consigam se comunicar com recursos dentro do sistema.

![Imagens](/imagens/pam01.jpg)

**Arquivos**

* /etc/pam.conf
* /etc/pam.d

**Configurações:**

A sintaxe do arquivo é separada em 3 campos exemplo:

```bash
Tipo Controle Modulo Parâmetros

```
***Tipo de autenticação:***

* **session**  - Algum processo que deve ser realizado após o login antes do usuario receber o acesso. ex: Exibir o MOTD.
* **account**  - Verifica se o usuario pode usar o serviço. ex: Checagem no sistema para ver se o usuario está ou não bloqueado.
* **password** - Definição referente a atualização da autenticação. **ex:** Verificação de token
* **auth**     - verifica a autenticidade do usurário. **ex:** Autenticação via ldap, kerberos, biometria etc.

***Controle:***

* **requisite** - Se o modulo falhar, todo o processo e interrompido.
* **required** - Se o modulo falhar o acesso é negado, mas os demais módulos serão invocados.
* **sufficient** - Se o modulo tiver sucesso é suficiente não importa se as outras falharem.
* **optional** - sucesso ou falha não e relevante, amenos que seja o unico.

***Módulo:***

* **pam_unix.so** - Relacionado com o passwd/shadow, autenticação de sistema.
* **pam_ldap.so** - Acesso via LDAP.
* **pam_cracklib.so** - Checagem de senhas fracas
* **pam_listfile.so** - Uso de arquivos externos de controle. obs: através desse modulo e possivel bloquear o acesso ssh de alguns usuarios através de um arquivo externo.
* **pam_console.so** - COntroole de acesso ao console por usuario.
* **pam_time.so** - recurso de controle por horario.
* **pam_sss.so** - uso do SSS
* **pam_krb5.so** - uso do kerberos 5

Obs:

No **Debian** os modulos estão localizados em: ***/lib/x86_64-linux-gnu/security/***

No Centos estão localizados em: ***/usr/lib64/security/***  

#### Pam com LDAP

```
auth sufficient pam_ldap.so
auth required pam_unix.so try_first_pass
```

* Se a autenticação de um usuário falhar o modulo será ignorado e os demais executados.
* Caso a autenticação não seja feita logo em seguida o pam requer uma autenticação local com a senha informada no modulo anterior, caso falhe novamente o processo é interrompido.

```
account sufficient pam_ldap.so
account required pam_unix.so
```

*  **Account** - é verificado se o login dará acesso a conta requisitada.

## SSSD (System Security Services Daemon)

Implementa melhoras no processo de autenticação do onde ele fornecerá uma interface entre o PAM, NSS e o sistema.

***Observações:***

* o SSD é visto bastante em autenticação usando o AD.
* Ele possui um arquivo único de configuração
* Usa cache, então os clientes mesmo Offlines conseguem realizar as autenticações.

## 210.4 LDAP (Lighweighted Directory Access Protocol)

É uma forma leve de um protocolo de acesso a diretórios, onde nós possibilita armazenar e gerenciar dados em uma base no modelo de arvore de diretórios.

**Características:**

* Muito usado para armazenar informações de usuários, equipamentos, funcionários etc.
* Modelo favorece a performasse na leitura porem desfavorece a escrita.
Cada nó representa um conjunto de atributos e valores

![Imagens](/imagens/ldap01.png)

* ***DC (Domain component)*** - Representa os componentes de um dominio (Nome, empresa etc.)
* ***OU (Organizational Unit)*** - Representa a organização de unidades.
* ***CN (Common Name)*** - Representa o nome comum de algum objeto.
* ***DN (Distinguished Nam)*** - O DN é realmente o nome completo da entrada usado para identificar um objeto dentro da hierarquia de diretórios.
* ***O (organizationName)*** - Armazena o nome da organização.

**Schemas** - São conjutos de ObjectClasses

**ObjectClasses** - São um conjunto de atributos que nós possibilita atribuir nome, Telefone, E-mail e ate mesmo cargo para um atributo.

**Pacotes:**

**Debian:**
* **slapd** - Server do LDAP.
* **ldap-utils** - Ferramentas do cliente LDAP.

**Centos:**
* **openldap** - Server LDAP.
* **openldap-servers** - Trás para o sistema os componentes do LDAP por exemplo os Schemas.
* **openldap-clients** - Ferramentas do cliente LDAP.


**Files Config:**

**Debian:**

* **/etc/slapd/slapd.conf** - Arquivo com a configuração principal do serviço.
* **/etc/slapd/slapd.d** - Diretório com a configuração principal do serviço
* **/etc/default/slapd** - Arquivo de parametrização do daemon.
* **/etc/slapd/ldap.conf** Arquivo do cliente ldap.

**Centos:**

* **/etc/openldap/ldap.conf** -  Diretório com a configuração principal do serviço.
