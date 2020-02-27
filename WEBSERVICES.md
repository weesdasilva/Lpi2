# **208.1**  - Implementando o servidor web.

O Apache é uma organização responsável por vários projetos como **Tomcat, Hadoop, FTP e httpd**.
* O httpd é um servidor web mais usado no mundo e vem se popularizando cada vez mais.
* Confira [Aqui](https://w3techs.com/)

## Pacotes:
**Debian:**
* apache2
* daemon: apache2

**Centos:**
* httpd
* daemon httpd

## Diretório de trabalho:

**Debian:**
* /etc/apache2


sites-available  - Sites em avaliação.pam_listfile
sites-enable       - Sites habilitados geralmente é um link simbólico para os Availables.

conf-available - Configurações habilitadas.
conf-enabled   - Sites ativos.


Observações:
apachectl é um link simbolico para o apache2ctl vv
apache é um binário modular como por exemplo o kernel

apache2.conf

DocumentRoot - Define qual o diretório que iria armazenar os arquivos de configuração.
Listen - parametro que seta em qual endereço e porta o servidor apache vai rodar.
Exemple: 66.66.66.66:80 ou 80
pam_listfileUser  e group - Seta qual usuário e grupo o apache ira rodar por padrão.
ServerAdmin - e-mail do administrador do servidor web.
ServerName - qual e o nome padrão do servidor web.
DocumentRoot - Onde está localizado os arquivos que serão servidos pelo servidor web.     

StartServers 7 - Define quantos processos pais serão iniciados ao iniciar o serviço do apache..
MaxClients 300 - Quantas conexões simultaneas cada processo filho irá tratar.

MinSpareServers 5
MaxSpareServers 25
Abertura máxima de instancias, minimo de 5 processos abertos e máximo de 25.
Caso esse valor for excedido com o tempo o apache irá matar esse exesso.
MinSpareThread
MaxSpareThread
Mesma usabilidade do minspareservers porém voltado para threads
Quantos processos filhos os pais poderam abrir.
ThreadsPerChild 25 - Quandos processos filhos por threads
MaxRequestsPerChild 4000 - quanpam_listfiletas requisições os processos filhos conseguiram tratar.
Depois que esse processo é usado 4000 ele é morto para não acumular lixo.
No debian esses parametros são carregados automaticamente pelo modulo mpm_event.conf.


Centos:
httpd
Nome do processo:
httpd

Diretório de trabalho:  "/etc/httpd"
run - Arquivo que armazena informações dos processos como PID.
Module: diretório quer armazena os ligs
Armazena os logs, link para ../../var/log/httpd
conf - armazena os principais arquivos de confugurações. httpd.conf
conf.d - guarda akgumass configuraçõed .

Instalando o modulo com PHP para o apache (httpd Centos 8).

Ao realizar a instalação do pacote php o mesmo instala por padrão o modulo do php.
/etc/httpd/modules/libphp5.so

/etc/httpd/conf.modules.d/10-php.conf
Arquivo responsável pela chamada do modulo php.

Já  o arquivo etc/httpd/conf.d/php.conf realiza a configuração dos parâmetros para o php:
FilesMatch -  Faz com que quando qualquer arquivo que termine com .php sejá interpretado pelo moulo do php.
AddType     - Fala que o .php irá trabalhar como txt para o php. ****** revisar
DirectoryIndex - Seta qual é o index para o php.

LogLevel - Parâmetro que define o nível do level que será gerado, essa opção define:
emerg
aler
crit
error
warn
notice
info
debug

LogFormat - Define o modelo do log.
%h - IP do host remoto.
%t - Quando ouve a conexão.
%l  - Log remoto
%u - Usuario.
%r - Primeira linha da requisição.
%s - status da requisição.
%b   - Bits da requisição.
%f  - Arquivo que foi acessado.
${Referer}i - referencia do acesso.
%{User-Agent} - Navegador de conexção.
Exemplo: LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio

CustomLog - Opção que define em qual arquivo será gravado os logs exemplo:
CustomLog "logs/access_log" combined
logs/access_log - Diretório que será armazenado o log.
combined              - Nome do alias criado no LogFormat.
É possível usar o | para executar um comando quando um site for acessado.

http://httpd.apache.org/docs/2.0/mod/ DOC











## Binario:
Apache2ctl - nos permite (gerenciar os processos do apache) como:
* Stop - para o daemon do apache.
* Startar - Inicia o daemn do apachpam_listfilee.
* Restart - Reinicia o processo do apache enviando o sinal de sighup ao processo.
* fullstatus - todo o status de execução do apache.
* graceful  - aguarda os processos atuais acabarem para depois reiniciar.
* graceful-stop stopa graciosamente.
* Server MPM: event - multi process modules.
* Prefork -  processo pai e outros filhos.
* Event - Trabalha com trades processos dentro de processos.
* work - -





















Os modulos de autenticação ficam em /etc/httpd/modules "link que aponta para /usr/lib64/httpd/modules"

mod_authn *- Módulos que dirão os meios de autenticação.
vfile, dbd, LDAP
mod_authz* - Módulos para autorização, permite um usuario fazer uma determinada ação.
host, owner, user.

Configurando autenticação no apache de forma basica:

A baixo estamos liberando o acesso ao acesso diretório que comportara o arquivo de banco dos usuários.

<Directory /opt>
   Options Indexes FollowSymLinks
   AllowOverride all
   Require all granted
</Directory>
Indexes - Responsável para que se caso não existir nenhum servidor de index o servidor irá fornecer automaticamente ao invés de fornecer uma saida de erro.
FollowSymLinks



<Directory /var/www/html/topsecret>
   AuthType Basic
   AuthName "Area secreta de acesso"
   AuthUserFile /opt/.htpasswd
  AuthGroupFile /opt/.htgroup
  Require group suporte
  Require valid-user
  Require user wesley
</Directory>

AuthGroupFile /opt/.htgroup
Require group suporte


apachectl configtest

<Directory /var/www/html/admin>
  <RequireAll>
    Require all granted
    Require not ip 192.168.1.210
  </RequireAll>
#Order Deny,Allow
#Deny from all
#Allow from 192.168.200.1
Require ip 192.168.200.11
Require ip 192.168.200.0/8
Require host dominioexemplo.com.br
</Directory>





Referencia documentações de paginas:
Aqui


Virtualhosts - Funcção do apache que possibilita ter vários sites em um mesmo servidor.

Syntax:

<VirtualHost *:80>
  ServerName "centos.example"
  ServerAlias "centos3.example"
  DocumentRoot /var/www/html
  Redirect /index.html /batata.html
  Alias /docs /var/ww/docs
</VirtualHost>

O bloco sempre ira iniciar e encerrar com <Virtualhost> </Virtualhost>
*:80 - Faz referencia ao endereço de ip que aquele VHOST irá responder
ServerName - Qual é o nome que aquele VHOST trabalhará.
ServerAlias - Forma de adicionar mais nomes ao vhost.
DocuentRoot - Diretório que tem o conteúdo que será apresentado.
Redirect - Redireciona um acesso para outro local, ao acessar index.html o acesso será jogado para batata.html obs: Também é possível usar sites como: "Redirect / http://google.com.br" tudo dentro do / será redirecionado para o google.
Alias: parecido com o redirect permite que quando digitado /docs seja apresentado o conteúdo de um outro diretório.

Userdir - Diretiva que permite a criação de uma área web para cada usuário criado no servidor.
Todo o conteúdo que estiver dentro de /home/user/public_html será apresentado via web.
A permissão do diretorio public_html dever ser igual a 755 para que o apache consiga apresentar o conteúdo da pasta.
Os arquivos dever ter a permissão 744 para que o apache consiga apresentar o conteúdo do arquivo.

Debian:

Arquivo do modulo fica em /etc/apache2/mods-available/userdir.conf
a2enmod userdir - para habilitar o modulo e criar um link de userdir.conf dentro de /etc/apache2/mod-enable
Syntax:

UserDir public_html
UserDir disabled root

Centos:

Arquivo do modulo fica em /etc/httpd/conf.d/userdir.conf

Syntax:
#UserDir disabled
UserDir public_html
Ambos:
<Directory "/home/*/public_html">
Parâmetro que define o diretório que estará o public_html

208.2 Apache configuration for HTTPS

HTTPS - (Secure HTTP ) É o protocolo http com segurança, que fornece uma comunicação entre duas pontas segura, utilizando os protocolos:
SSL: Secure Socket Layer
TLS: Transport Layer Security
Obs: O httpd utiliza esses 2 protocolos, onde o TLS é a evolução do SSL pois já foram encontrado vulnerabilidades nos algorítimos do SSL.

Fluxo de comunicação:

This diagram illustrates the SSL or TLS handshake as described in the text preceding the diagram.

1) O cliente envia quais os algorítimos o mesmo entende para se comunicar com o servidor.
2) Resposta do servidor CiptherSuite (Forma como ira haver a comunicação.) e o certificado do dominio.
3) Cliente ira verificar o certificado em uma CA para ver se é um certificado seguro.
4) O cliente irá enviar as informações de sua chave para haver uma criptografia assimétrica parecida com a do SSH.


HTTPS geração do certificado.

1)  O cliente ira gerar o CSR arquivo que contem varias informações referente ao domínio, empresa e informaões da maquina que hospedara o serviço.
2) o CSR é enviado para uma empresa CA onde a mesma será responsavel por validar aquelas informações.
3) Com o certificado validado é gerado um novo arquivo chamado CRT que é o CSR validado.
4) O administrador instala o certificado.


obs:
É utilizado o pacote openssl para gerar os certificados.
O pacote mod_ssl habilita o modulo do ssl no centos.
Após a instalação do pacote o modulo ficara em /etc/httpd/conf.modules.d/00-ssl.conf e o mesmo criara um arquivo dentro de /etc/httpd/conf.d/ssl.conf
O parametro SSLEngine irá habilitar o SSL no servidor.
Listen 443 - lista a porta do ssl.
Gerando certificado:
obs: Uma boa pratica é gerar e manter todos os certificados em /etc/ssl/certs que é um link para /etc/pki/tls/certs

1. Gerando a chave para gerar o csr.
  openssl genrsa -des3 -out key.key 1024
openssl - Binario de geração.
genrsa - gerarar um certificado
-des3 - criptografia usada no certificado.
- out   - Nome de chavegerada.
1024 - tamanho da chave gerada.
2. Gerando csr
  openssl req -new -key key.key -out csr.csr
openssl - Binario de geração.
req - requisição de certificado.
-new criar um novo certificado.
-key - caminho da chave gerada.
-out saida com o nome do certificado.
3. Criando o CA propio - O arquivos de CA é gerado apartir de um script que está em:
  /etc/pki/tls/misc/CA -newca

Aplicando SSL em um VHOST:

<VirtualHost *:443>
  ServerName ssl.centos.example
  DocumentRoot /var/www/html/site-ssl
  SSLEngine on
  SSLCertificateFile /etc/ssl/certs/centos.crt
  SSLCertificateKeyFile /etc/ssl/certs/centos.key
  SSLCACertificateFile /etc/pki/CA/cacert.pem
    <Directory /var/www/html/site-ssl/cert>
      SSLVerifyClient require
    </Directory>
</VirtualHost>

SSLEngine on                 - Habilita o ssl.
SSLCertificateFile         - Path do certificado aplciado.
SSLCertificateKeyFile  - path da key do certificado.
SSLCACertificateFile    - Path do CA arquivo da certificadora.
SSLVerifyClient require - Solicita a verificação dos arquivos de certificado
none - nenhum certificado de cliente é necessário
opcional : o cliente pode apresentar um certificado válido
require -  cliente deve apresentar um certificado válido
optional_no_ca -  o cliente pode apresentar um certificado válido, mas não precisa ser verificável (com sucesso). Não é possível confiar nessa opção para autenticação do cliente.

Gera o arquivo p12 para descriptografar uma pagina com um certo conteúdo.
    openssl pkcs12 -export -inkey usuario.key -in usuario.crt -out usuario.p12

Configurações extras de segurança:

O arquivo /etc/httpd/conf.d/ssl.conf irá configuraras diretivas do SSL.

SSLProtocol - All - SSLv2 -SSLv3 - define quais as versões de protocolo o servidor irá suportar. nesse caso todos os protocolos serão aceitos  menos os -SSLv2 -SSLv3. Também é possivel -All +TLSv1.2: remove tudo porém libera o TLS na versão 1.2
SSLCipherSuite HIGH:3DES:!aNULL:!MD5:!SEED:!IDEA - Quais algoritmos de criptografia serão usado.
ServerTokens
Full - todas as informações do servidor.
Os - Apenas o sistema operacional.
Prod - Apenas informações do serviço como Apache
ServerSignature on - Irá exibir a assinatura que o servidor irá mostrar pra você.

Referencia: https://httpd.apache.org/docs/2.4/mod/core.html#serversignature

TraceEnable off - modulo de consultar varis informações do servidor.

Sni (Server name indicate)

Extensão que possibiltia o uso de virtualhost por nomes em acesso https caso esse recurso não exista cada vhost terá que apontar para um ip.

Tecnica que aponta qual certificado um determinado vhost ira fornecer a um cliente.:

https://www.globalsign.com/pt-br/blog/what-is-server-name-indication/



Squid

Serviço que proxy que visa filtrar a conexão que sai de uma rede, com ele é possivel: bloquear o acesso a um site especifico, realizar cache de navegação e também trabalhar com autenticação.

Caracteristicas:

Nome pacote: squid
/etc/squid/squid.conf - Principal arquivo de configuração.

squid -v
Mosta a versão é as opções que atualmente estão habilitadas
squid -k
Possibilita reconfigurar matar etc.

Syntax squid.conf

http_port 3128 - porta padrão do proxy.

Tipos de ACLS:

src ip/REDE
dst IP/REDE
srcdomain .google.com www.debian.org
dstdomain mesma coisa
port porta
proto HTTP HTTPS FTP
browser navegador
time z 09:00-18:00 (segunda a sexta das 9 as 18)
url_regex uol ( O uol sera bloqueado www.uol.com.br)
urlpath_regex  esportes (apenas o www.uol.com.br/esportes sera bloqueado)

auth_param basic realm Por favor identifique-ce para conseguir acesso
auth_param basic prom /usr/lib64/squid/



NGINX

yum install nginx
http {  -inicia um bloco de http
server - ira definir os blocos de VHOSTS
listen  - ira listar a porta que o vhost ira escutar
server_name  centos.example;  - nome de dominio
root - onde está o seu site
index


FastCGI - fornece uma interaçãoa entre o webserver e alguma aplicação como php.
