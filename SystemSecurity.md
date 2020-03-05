# Segurança do Sistema.


## 212.1 Configurando um roteador.

### Classes de IP:

Existem 3 classes de ips principais (A, B e C).

  Classes       | Primeiro Octeto  | Range                           | IPS Privados                       |
  --------      | -------------    | ---------                       | ------------                       |
  **A**         | **1-126**        | **1.0.0.0 - 126.255.255.255**   | **10.0.0.0 - 10.255.255.255**      |
  **B**         | **128-191**      | **128.0.0.0 - 191.255.255.255** | **172.16.0.0 - 172.31.255.255**    |
  **C**         | **192-223**      | **192.0.0.0 - 223.255.255.255** | **192.168.0.0 - 192.168.255.255**  |

* O range **127.0.0.0** é dedicado a identificação local da maquina.
* O range Privado são as redes que podem ser usados dentro de uma rede interna.

### Cenário

Temos 3 maquinas em nosso ambiente:

**Centos:**

* IPs: 10.10.0.2 / 172.16.100.101

**Debian1:**

* IPs: 172.16.100.102

**Debian2:**

* IPs: 10.10.0.3

Por padrão a maquina **Debian1** não consegue se comunicar com a maquina **Debian2** por falta de rota, nesse modulo faremos com que a maquina **Centos** seja o nosso **gatway** de comunicação destas duas maquinas.

### Habilitando o repasse re pacotes:

Primeiro iremos habilitar o repasse de pacotes para que a maquina **Centos** consiga entregar pacotes de uma rede para a outra, edite o arquivo **/etc/sysctl.conf** e adicione a seguinte linha:

```bash
net.ipv4.ip_forward = 1
```  
* Em seguida execute o comando **sysctl -p** para o parametro ser aplicado

Conseguimos válidar se o parametro foi habilitado execute:

```bash
cat /proc/sys/net/ipv4/ip_forward
```
* Se o resultado for igual a **"1"** o repasse está habilitado, se for igual a **"0"** o repasse está desabilitado.

### Criando rotas entre as maquinas.

Maquina **Debian1**

```bash
ip route add 10.10.0.0/24 via 172.16.100.101
```

* Todo o pacote que sair para a rede **10.10.0.0** será encaminhado para a maquina **172.16.100.101** "Centos"

Maquina **Debian2**

```bash
ip route add 10.10.0.0/24 via 172.16.100.101
```

## Netfilter e IPTABLES

### Netfilter
 * é um recurso do kernel linux que nos posibilita fazer uma tratativa de todos os pacotes que entram ou saem de uma maquina.

### Iptables
*  Binário que gerencia o Netfilter

### Tabelas

O netfilter usa tabelas que são um grupo de regras

* **filter** - Tabela padrão que é usada para filtrar os pacotes.
* **nat**    - Tabela usada para manipular pacotes que geram novas conexões alterando seu endereço.
* **mangle** - realiza alterações nos pacotes.

### Chains

 É onde são armazenas as regras de cada tabela.

 * **INPUT**   - Entrada no host local
 * **OUTPUT**  - Saida do host local
 * **FORWARD** - Pacotes sendo encaminhados para outra rede
 * **PREROUTING** - Prerotiamento de um pacote, antes do mesmo ser roteado.
 * **POSTROUTING** - Pacote sendo enviado a uma rede remota.


### Comandos de Gerenciamento

Todo o gerenciamento do netfilter e feita utilizando o binario **iptables**

#### Listando tabelas

```bash
iptables -t filter -L
```
* **-t** - seleciona uma tabela ex: filter.
* **-L** - Lista todas as chains com suas regras.
