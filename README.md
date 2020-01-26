# LPI 201 - 202
Esse Markdown foi feito para ajudar a todos que querer conquistar a LPIC-2 Engenheiro Linux

**_Tópico das provas:_**

201

| Tópico                             | Questõeos     |
| -------------                      |:-------------:|
| Planejamento de Capacidade         | 8             |
| Linux Kernel                       | 2             |
| Inicialização do Sistema           | 9             |  
| Sistema de Arquivos e Dispositivos | 9             |
| Administração avançada de dispositivos de armazenamento | 8             |   
| Configuração de Rede               | 11            |   
| Sistema de Manutenção              | 6            |   


202

| Tópico                            | Questõeos     |
| -------------                     |:-------------:|
| Domain Name Server                | 8             |
| Serviços Web                      | 11            |
| Compartilhamento de arquivos      | 8             |  
| Gerenciamento de clientes de rede | 11            |
| Serviços de e-mail                | 8             |   
| Segurança do sistema              | 13            |   

# **207.1**  Configuração básica do servidor DNS.

# O que é?
Dns é vem da sigla Domain name system - É um serviço que realiza a tradução de um endereço de nome para IP. Onde também é possivel realizar a tradução de um endereço para nome.

# Pacotes:

# _Debian_
* **bind9** - _Servidor DNS_
* **bind9utils** - _Ferramentas para consulta DNS_
* **bind9-doc** - _Documentação do bind_

# _Centos_
* **bind** - _Servidor DNS_
* **bind-utils** - _Ferramentas DNS_

**DNS Resolver:**
* Software ou biblioteca responsavel por fazer a toda a consulta DNS para o client.
```bash
ping google.com
which ping
ldd /usr/bin/ping
#Resultado
libresolv.so.2 => /lib/x86_64-linux-gnu/libresolv.so.2 (0x00007fe9e0075000)
```

# Tipos de DNS:
Existem 4 tipos de servidores de dns:

Primary (Master)

* Tem autoridade sobre um domínio e é responsável por armazenar as zonas DNS de um domínio.
* Obrigatório

Secundary (Slave)

* Serve como um servidor secundário que assume uma zona DNS temporariamente caso o **Master** venha a cair.
* Também consegue ter autoridade sobre um domínio
* Opcional

Caching

* Armazena o cache de uma consulta DNS.
* Não tem autoridade sobre um domínio
* Opcional


Forwarding

* Pode ser um tipo de servidor de caching
* Encaminha a resolução de nomes para outro servidor DNS e retorna o resultado para os clientes.
* Opcional

# **Como funciona uma consulta DNS:**

**Domain Name Space:**

* Mostra como funciona um sistema de resolução de nomes


![Image of Yaktocat](/imagens/dns01.png)

Tudo começa com a consulta do "**.**" que são o **Root Domain**, servidores gerenciados pela ICCANN que ajuda a encontrar um endereço na arvore de domínios.

Depois são consultados os TLDs (Top Level Domains) que são toda a terminação de um dominio ex: .br .edu .com

FLD (First Level Domain) é a indicação em si do dominio ex: redhat.com.

Hosts/Subdominios - Um subdominio ex: contato.redhat.com.

**Domain Name Space Zones**

Para gerenciar os Root Domain existem os NS (Name Servers) que são os servidores que gerenciam e tem as informações dessa zona de DNS.

* Obs: Os Root Domain são 13 grupos de servidores divididos pelo mundo responsáveis pela administração do iniciao de uma consulta.


# **Arquivos de configuração:**

**Centos:**

* /etc/named.conf - Armazena ar principais configurações do serviço.
* /etc/name.db

**Debian**

* /etc/bind/named.conf - Arquivo que realiza os includes da configuração do bind.
* /etc/bind/named.conf.options - Armazena as configurações do Serviços.
* /etc/bind/named.conf.local   - Armazenar as zonas locais de DNS.
* /etc/bind/named.conf.default-zones - Armazena as zonais padrões do serviço.

```bash
options {
	listen-on port 53 { 127.0.0.1; };
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	recursing-file  "/var/named/data/named.recursing";
	allow-query     { localhost; };

	recursion yes;

	dnssec-enable yes;
	dnssec-validation yes;

	/* Path to ISC DLV key */
	bindkeys-file "/etc/named.root.key";

	managed-keys-directory "/var/named/dynamic";

	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";
};

```

* **listen-on** - Parâmetro do arquivo que define qual a porta e Rede que o serviço irá trabalhar;
* **listen-on-v6** - Idem para IPV6
* **directory** - Define qual é o diretório com as configurações do serviço.
* **dump-file** - Onde será gerado todo o dump de  cache armazenado pela aplicação.
* **statistics-file** - Onde será armazenada todas as estatísticas da aplicação.
* **memstatistics-file** - Estatísticas de Memoria.
* **recursing-file** - Onde será gravado os dados de consulta recursiva.
* **allow-query** - Especifica quais hosts em permissão para fazer uma pergunta sobre dns.
* **recursion** - se _yes_ será habilitado a consulta recursiva.
* **dnssec-enable** - Esta opção é obsoleta e não tem efeito.
* **dnssec-validation** -  Habilita a validação de chaves Obs: se **yes** será utilizado uma chave estatística; **auto** validação automática.
* **bindkeys-file**- Chave usada pelo dnssec.
* **managed-keys-directory** - Especifica o diretório no qual os arquivos que rastreiam as chaves DNSSEC gerenciadas
* **pid-file** - Onde será armazenado o PID do processo do bind.
* **session-keyfile** Parâmetro que indica a chave que sera usada para a comunicação entre o master e o slave em transferencia de zonas por ex. (TSIG).




Obs: **_DNSSEC_** - Visa obter segurança em consultar recursivas utilizando uma chave validadora.

Referencia: https://bind9.readthedocs.io/en/latest/reference.html

```bash
zone "." IN {
	type hint;
	file "named.ca";
};
```

* **_zone "." IN_** - Indica o inicio de uma zona de DNS.
* **type hint;** - define o que o servidor será para aquela zona de DNS
* **file** - Onde será armazenado a zona daquele domínio.

obs: Tipos de entrada:

* hint - indica m servidor de cache
* master - servidor Master
* slave - servidor secundario.

# **Realizando consulta usando o servidor DNS**

Os comando usados para se fazer uma tradução são o **dig** e **host**

```bash
host google.com 127.0.0.1
```
Obs: No host basta usar o ip do servidor que você quer usar como tradutor

```bash
dig google.com @127.0.0.1
```
Obs: No dig temos que colocar um @ na frente do endereço.

# **Comandos de Gerenciamento**
**RNDC - Remote Name Daemon Control (Controle de Daemon de Nome Remoto)** - É um binario que gerencia o nosso bind9.

Parâmetros:
* status - Verifica o status do servidor DNS.
* reload - Recarrega toda a configuração do bind.
* flush - Limpra o cache de dns.
* reconfig -  Reconfigura apenas os arquivos de configuração e zona
