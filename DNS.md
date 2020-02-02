# **207.1**  Configuração básica do servidor DNS.

# O que é?
DNS (Domain name system) - É um serviço que realiza a tradução de um endereço de nome para IP e também é possível realizar a tradução de um endereço IP para nome.

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

Existe formas de verificar se a sintax do arquivo de configuração estão corretas:

**Padrão:**
* **named-checkconf** - binario parão do named que checa por padrão as configurações do arquivoo /etc/named.conf
* **named-checkzone**

**RNDC - Remote Name Daemon Control (Controle de Daemon de Nome Remoto)** - É um binario que gerencia o nosso bind9.

Parâmetros:
* **status** - Verifica o status do servidor DNS.
* **reload** - Recarrega toda a configuração do bind.
* **flush** - Limpra o cache de dns.
* **reconfig** -  Reconfigura apenas os arquivos de configuração e zona

# **Loggin in named**

É possivel gerarar varios logs no named, no exemplo abaixo estamos gerando um log com um nível dinâmico de todas as requisições de tradução de endereço.

```bash
logging {
        channel weslley {
           file "data/requisicoes.log";
           severity dynamic;
        };
		category queries {
		   weslley;
        };
};

```
* logging - Define que será gerado um log
* channel - define 	um nome de bloco
* file    - aonde será escrito os logs gerenciados
* severity - Trabalha com tipos de erros (critical, warn, error) dynamic irá trabalhar com todos os níveis de erros.
* category - define o que será armazenado dentro do arquivo (queries, config, rede)
* weslley referencia o channel onde os logs de queries serão gravados.

 Referencia de [Parâmetros](https://www.zytrax.com/books/dns/ch7/logging.html)


# **Zonas de DNS**
Uma zone de Dns é basicamente a um arquivo com varias entradas de DNS para um endereço de domínio.

```bash
zone "weesdasilva.ops" IN {
        type master;
        file "weesdasilva.zone";
};
```
* **zone** - Indica o nome do dominio.
* **type** - Fala o que o servidor é para aquele domínio (master, slave, cache)
* **file** - arquivo que contem as entradas de DNS daquele dominio.

**Arquivo de zona:**

```bash
$TTL 1h
@ IN SOA centos.weesdasilva.ops. admin.weesdasilva.ops. (
		01     ; serial
		28800  ; refresh (8h)
		7200   ; retry (2h)
	    604800 ; expire (7d)
		3600   ; negative caching (1h)	 
)

          NS centos.weesdasilva.ops.
@    IN   NS debian.weesdasilva.ops.
          MX 5  mail
					MX 10 mail2
@      IN A 10.10.0.1
centos  A   10.10.0.1
debian  A   10.10.0.2
mail    A   10.10.0.1
mail2   A   10.10.0.1
```
* **$TTL** - É o tempo  que o cache será valida para o cliente obs: e possivel passar esse tempo em "s" "m" "h"
* **@ IN SOA centos.weesdasilva.ops. admin.weesdasilva.ops.** - **@** representa o nome de domino, **IN SOA** - Delega a autoridade de um dominio a um NS **admin.weesdasilva.ops** - Define um e-mail para contato na zona.
*  **20200201     ; serial** - Representa o numero de alterações em sua zona usado para controle  do slave, então se o slave tiver armazenado uma versão inferior que o serial do servidor o mesmo irá baixar as novas entradas, caso ao contrario o slave não ira fazer nada.
* **28800         ; refresh (8h)** - Tempo que o servidor slave irá consultar o master procurando novas entradas
* **7200   ; retry (2h)** - Caso o master não responda o retry devine quando o slave irá tentar uma nova conexão.
* **604800 ; expire (7d)** - Sem uma resposta o expire define quanto tempo a zona enviada pelo master será valida.
* **3600   ; negative caching (1h)** - tempo que os clients irão armazenar uma resposta negativa do server.

Logo após isso se inicia as entradas da zona de dns.

**Criando servidor Slave**

A configuração do servidor slave será feita em um debian, então vasta editar o arquivo **/etc/bind/named.conf.local**

```bash
zone "weesdasilva.ops" {
    type slave;
    masters { 10.10.0.1; };
	file "weesdasilva.zone";
};
```

* **zone** - Cria uma zona de dns para o dominio weesdasilva.ops
* **type** - Define o que o servidor será para aquela zona de DNS **slave**
* **masters** - Aponta um servidor master.
* **file** - Aonde será gravada todas as entradas recebidas.

Para forçar uma transfereica de zona basta executar:

```bash
dig @10.10.0.1 axfr weesdasilva.ops
```

Podemos dar um **cat** em **/var/named/data/named.run** e verificar se houve alguma transferencia de zona.

```bash
client @0x7f3a96ef32d0 10.10.0.2#33049 (weesdasilva.ops): transfer of 'weesdasilva.ops/IN': AXFR started (serial 1)
client @0x7f3a96ef32d0 10.10.0.2#33049 (weesdasilva.ops): transfer of 'weesdasilva.ops/IN': AXFR ended
```

Por padrão a zona é criptografada e apenas consegue ser lida pelo servido named, se quisermos verificar o seu conteudo basta executar o comando abaixo:

```bash
named-compilezone -f raw -F text -o weesdasilva.txt weesdasilva.ops weesdasilva.zone
```
* **named-compilezone** - binário que irá descriptografar a zona.
* **-f raw** - Formato do input **raw**
* **-F text** - Formato do output **text**
* **-o** - Nome do arquivo que será gravado weesdasilva.text
* **weesdasilva.ops** - Dominío da zona.
* **weesdasilva.ops.zone** - onde está localizado o arquivo da zona.

**Criando servidor Forwarding**

Basta adicionar o bloco de encaminhamento no principal arquivo de configuração do bind.
```bash
forwarders {
    10.10.0.1;
  };
```

Assim toda solicitação de resolução de nomes será encaminhada para um servidor externo e repassada para o seu cliente.

O refirecionamento anterior funciona apenas com resoluções de dominio externos, caso você queira redirecionar as requisições de apenas um dominio basta criar uma zona de encaminhamento.

```bash
zone "weesdasilva.ops" {
	type forward;
	forwarders { 10.10.10.1; };
};
```

**Configurando DNS reverso.**

O DNS reverso serve para que seja possível ter a tradução de endereço de IP para nome de domínio, o mesmo e muito usado em serviço de email onde visa verificar a autenticidade de um domínio evitando assim praticas de SPAM.

O primeiro passo é adicionar uma zona no arquivo de configuração do bind.

 ```bash
 zone "0.10.10.in-addr.arpa" IN {
	type master;
	file "weesdasilva-rev.zone";
};
 ```
* O arquivo segue a sintax padrão de criação de zona.

Depois crie as entradas para o DNS reverso.

 ```bash
 $TTL 1h
@ IN SOA centos.weesdasilva.ops. admin.weesdasilva.ops. (
        01     ; serial
        28800  ; refresh (8h)
        7200   ; retry (7d)
        604800 ; expire (7d)
        3600   ; negative caching (1h)     
)

             NS centos.weesdasilva.ops.
@      IN    NS debian.weesdasilva.ops.

1      PTR   centos.weesdasilva.ops.
2      PTR   debian.weesdasilva.ops.
4      PTR   desktop.weesdasilva.ops.

 ```
* A principal diferença fica por parte das entradas **PTR** onde por exemplo quando for efetuado uma tradução de **10.10.0.1** será apresentado o dominio **centos.weesdasilva.ops**  

# **207.3 Securing a DNS server**

A segurança em um servidor DNS é algo muito critico onde deve ser tratada de forma cuidadosa

**Pontos importante:**

### 1) O serviço do bind **não** deve estar rodando com o usuario Root.
```bash
[root@centos named]# ps aux | grep named
named     2372  0.0 21.5 233036 107312 ?       Ssl  Feb01   0:00 /usr/sbin/named -u named -c /etc/named.conf
```
* Por padrão o usuario que irá manter o serviço no ar e gerenciar os arquivos da aplicação é o named **(Centos)** e bind **(Debian)**.
* Isso é configurado em:
* **Debian**: /etc/default/bind9
* **Centos**: /lib/systemd/system/named.service

### 2) Sempre manter o software atualizado para evitar bugs de versões.

Formas de se verificar a versão do bind:

**RNDC**:

```bash
[root@centos named]# rndc status
version: BIND 9.11.4-P2-RedHat-9.11.4-9.P2.el7 (Extended Support Version) <id:7107deb>
```

**named:**

```bash
[root@centos named]# named -v
BIND 9.11.4-P2-RedHat-9.11.4-9.P2.el7 (Extended Support Version) <id:7107deb>
```

**dig:**

_Também é possivel verificar qual e a versão do serviço de dns instalada no servidor através da ferramenta dig_

```bash
dig @10.10.0.1 chaos version.bind txt
;; ANSWER SECTION:
version.bind.		0	CH	TXT	"9.11.4-P2-RedHat-9.11.4-9.P2.el7"
```

Uma boa praticá é bloquear essa informação para o mundo, dentro do arquivo named.conf adicione a opção a baixo:

```bash
version "Não te interessa";
```
* Com isso sempre que alguem fizer uma requisição para saber a versão do serviço será apresentado uma mensagem em texto plano.

### 3) Limitar o acesso ao seu servidor atraver do named.conf

Atráves do named.conf é possivel configurar de varias formas diretivas de bloqueio e aceitação de requisoções:

```bash
allow-query { localhost; 10.10.0.0/24; };
```
* Parâmetro que limita as requisições para um IP ou rede.

```bash
blackhole { 10.10.0.4; }
```
* Parâmetro que bloqueia toda tentativa de requisição para um endereço ou rede.

```bash
allow-recursion { 10.10.0.4; };
```
* Limita a consulta recursiva para um endereço de IP ou rede.

```bash
allow-transfer { 10.10.0.2; };
```

* Limita a transferência de zona para um IP ou rede.
* Também e possivel limitar a transferência apenas a um domínio definindo o bloco dentro da zona criada.

ACLS:

Conseguimos trabalhar também com lista de controle de acesso para deixar a configuração mais simples.

```bash
acl "maquinas-slave" {
	10.10.0.1;
	10.10.0.2;
};

allow-transfer { maquinas-slave; };
```
* O bloco de **ACL** deve estar fora do bloco de **options**

## TSIG - Transaction Signature
O tsig  promove a comunicação entre 2 serviçõs de dns utilizando um par de chaves.

O primeiro passo é gerar o par de chaves no servidor:

```bash
dnssec-keygen -a HMAC-MD5  -b 512 -r /dev/urandom -n HOST weesdasilva.ops
```
* dnssec-keygen - binario que irá gerar a chave.
* -a HMAC-MD5 - algoritimo usado
* -b 512 - a quantidade de bips que será usada na chave.
* -r /dev/urandom - Da onde  o binario irá pegar os caracteres para a criptografia.
* -n HOST - nametype o que ira usar a chave e o nome da chave.

Depois vamos preparar o server para apenas permitir por exemplo uma transferência de zona usando chaves, basta acrescentar no named.conf a seguinte entrada:

```bash
key chave {
    algorithm HMAC-MD5;
    secret "bIB4KDNEtn2wnh7dAkD5gwVWvklZqXv8P8Z03E91SehFrAtAJO7acM1zsyStePO6G/aOjwm/RcpIDZHuufCnNw==";
};

allow-transfer { key chave; };

```
* **key chave** - define um nome a chave a ser usada.
* **algorithm** - declara o algoritimo que foi usado para gerar a chave.
* **secret** - passa a chave a ser usada
* **allow-transfer { key chave; };** - limita a transferencia apenas aos clientes que tem a chave.


Agora vamos no cliente definir que em toda a comunicação o mesmo ira usar um par de chaves

```bash
key chave {
    algorithm HMAC-MD5;
    secret "bIB4KDNEtn2wnh7dAkD5gwVWvklZqXv8P8Z03E91SehFrAtAJO7acM1zsyStePO6G/aOjwm/RcpIDZHuufCnNw==";
};

server 10.10.0.1 {
    keys { chave; };
};

```
* A mesma configuração e passada no cliente
* **server 10.10.0.1** - define que em toda a comunicação com o servidor 10.10.0.1 a key "chave" sera usada.

Por fim com o rndc force uma nova transferencia de zona.
```bash
rndc retransfer weesdasilva.ops
```
* retransfer força a transferencia de zona de um dominio especifico.

### DNSSEC -  Domain Name System Security Extensions
Usando um par de chave você assina sua zona de dns e apenas irá se comunicar com você quem tem a sua chave publica, isso garante autenticidade pois apenas o seu servidor pode fornecer a zona de acordo com a chave publica.

 Gerando a chave do DNSSEC:

 ```bash
 dnssec-keygen -a DSA -b 1024 -r /dev/urandom -n ZONE weesdasilva.ops
 ```

 Assinando zona:
 ```bash
 dnssec-signzone -P -r /dev/urandom -o weesdasilva.ops weesdasilva.zone chave.private
```

### DANE - Based Authentication of Named Entities
BAsicamente o dane garante que um dominio ira responder por apenas uma CA em uam comunicação SSL/TLS

### Chroot Jail

É o ato de enjaular a sua aplicação, basicamente o chroot é uma camada de segurança que permite executar a sua aplicação de forma apartada ao sistema operacional, então se algum hacker através de alguma vulnerabilidade acessar o seu servidor o mesmo não terá acesso real ao seu sistema mais sim  ao ambiente apartado.
