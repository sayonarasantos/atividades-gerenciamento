# atividades_gerenciamento

## snmpIpRouteTable.sh
- Objetivo da prática: Criar um script que capture a tabela de rotas de um host remoto usando consultas SNMP.
- Cenário testado
  - Agente: Máquina virtual com o sistema operacional Xubuntu 18.04, criada usando VirtualBox com placa de rede em modo Bridged.
  - Gerente: Notebook com o sistema operacional Ubuntu 18.04.

### 1. Configuração das máquinas
#### 1.1. Configuração do Gerente
Na máquina do gerente, instale o pacote “snmp” com o seguinte comando:
```
$ sudo apt-get install snmp
```
#### 1.2. Configuração do Agente
Primeiramente, instale o pacote snmpd com o seguinte comando:
```
$ sudo apt-get install snmpd*
```
Em seguida, altere o arquivo de configuração do pacote instalado
```
$ sudo nano /etc/snmp/snmpd.conf
```
Nesse arquivo, libere o acesso ao agente por uma máquina externa, comentando a linha: `agentAddress udp:127.0.0.1:161` e descomentando a linha: `agentAddress udp:161,udp6:[::1]:161`

Depois, é necessário criar uma nova comunidade chamada “gerente” com acesso a MIB. Para isso, adicione as seguintes linhas no mesmo arquivo:
```
com2sec secName default gerente
group secGroup v1 secName
group secGroup v2c secName
view mib2 included .1.3.6.1.2.1
access secGroup "" any noauth exact mib2 none none
```
Após as edições, reinicie o serviço com o comando: 
```
$ sudo service snmpd restart
```
### 2. Execução dos scripts
Para executar este script, é necessário indicar o ip do host, onde o agente está instalado. Então, pelo terminal da máquina gerente, digite o seguinte comando:
```
$ sh snmpIpRouteTable.sh ip_host
```
A reposta ao este comando deve ser um tabela com as seguintes colunas:
- IpRouteDest: o ip de destino
- Interface: a interface local, da qual o próximo salto ocorrerá
- NextHop: o ip do próximo salto
- Type: o tipo de rota (3 - direta ou 4 - indireta)
- Proto: o mecanismo utilizado para aprender a rota
- Mask: a máscara da rede

### Referências
- Object Identifiers. Alvestrand Data. Disponível em: https://www.alvestrand.no/objectid/1.3.6.1.2.1.4.21.1.html. Acesso: 16 nov. 2019.
- Aprenda SNMP e MIB-II usando Shell Script.  Fernando Tsukahara. YouTube. Dísponível em: https://www.youtube.com/watch?v=z96MSdmeviA. Acesso: 16 nov. 2019
