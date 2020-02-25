# Tópico 211: E-Mail Services

## 211.1 Usando Servidores de E-mail

Um servidor de e-mail nos possibilita trocar mensagens entre dois domínios como e demonstrado no fluxograma a seguir.

![Imagens](/imagens/email01.jpg)

O primário passo é formatar a mensagem que o cliente deseja enviar passando remetente e destinatário, isso é feito atráves de uma ***MUA - Mail User Agent***
* **Outlook**
* **Thunderbird**

Toda mensagens é disparada por uma ***MTA (Mail Transfer Agent)*** que utiliza o protocolo ***SMTP - Simple Mail Transfer Protocol***

**Portas:**

* **25** - SMTP
* **443** - SMTPS

O ultimo passo é resgatar as mensagens de um servidor de email, pra isso é utilizado um **MDA - Mail Delivery Agent** que usa os procotolos ***IMAP - Internet Message Access Protocol*** ou ***POP3 - Post Office Protocol***

**Portas:**

* **143** - IMAP
* **993** - IMAPS
* **110** - POP3
* **995** - POP3S

## Postfix

É atualmente a MTA mais utilizada no mercado.

**Pacote:**

Tanto no Debian quanto no Centos o nome do pacote é:

* **Postfix**

**Processos:**

* **master** - Maestro dos subprocessos gerados pelo postfix.
* **pickup** - Processo que capta as mensagens de email,.
* **qmgr**   - Realiza o roteamento das mensagens para as filas especificas de e-mail.

**Filas:**

As filas de emails por padrão são ficam em:

* **/var/spool/postfix/**

Já as mensagens de e-mails dos usuários são armazenadas em:

* **/var/mail** ou **/var/spool/mail**

**Files Config:**

Os arquivos de configuração ficam dentro de **/etc/postfix/**

**master.cf** - Arquivo que passa parâmetros para o processo **master** como processos que o master irá invocar ou habilitar alguma funcionalidade ex: **smtps**.

**main.cf**   - Realiza as configurações principais do serviço de email.
* **myorigin** = $myhostname - Origem de envio.
* **mydestination** = define quais endereços o seu servidor de mail ira aceitar.
* **mynetworks** - seta as redes que são confiáveis.
* **relay_domains** - configura um servidor de encaminhamento local.

## Enviando email via TELNET

Conectado no telnet siga os seguintes passos:

```
HELO localhost
250 centos.localdomain
MAIL FROM: root
250 2.1.0 Ok
RCPT TO: wees
250 2.1.5 Ok
DATA
354 End data with <CR><LF>.<CR><LF>
Ola Amigo
.
```
* **HELO** - Inicia uam conversa com um servidor de email.
* **MAIL FROM:** - Define um Remetente da mensagem
* **RCPT TO:**   - Define um destinatario.
* **DATA** - Inicia o bloco de mensagem.
* **.** - Encerra a mensagem e envia o email.
