#!/bin/bash

###############################################################################
# 
# Descrição:
# Este script captura a tabela de rotas de um host remoto usando consultas SNMP
#
# Dependências: (Ver README.md para maiores detalhes)
# 	- Na máquina do gerente (onde o script será executado), o pacote snmp deve
# 	estar instalado;
# 	- Na maquina do agente, o pacote snmpd deve estar instalado, e a comunidade
# 	"gerente" deve estar configurada.
#
# Execução do script:
# 	Para executar este script, e necessário indicar o ip do host, onde o agente
# 	está instalado. Então, pelo terminal, digite o seguinte comando:
# 		$ sh ipTableMIB.sh ip_host
# 	A reposta ao este comando deve ser um tabela com as seguintes colunas
# 		- Dest: o ip de destino
# 		- Interface: a interface local, da qual o próximo salto ocorrerá
# 		- NextHop: o ip do próximo salto
# 		- Type: o tipo de rota (1-other, 2-invalid, 3-direct, 4-indirect)
# 		- Proto: o mecanismo utilizado para aprender a rota (1-other, 2-local,
# 		3-netmgmt, 4-icmp)
# 		- Mask: a máscara da rede
#
###############################################################################

# $1: parametro recebido via terminal, é ip do host que será consultado

BRANCH=".1.3.6.1.2.1.4.21.1" # Caminho do objeto ipRouteEntry da MIB, que possue infomações sobre tabela de rotas
IPs_route=$(snmpwalk -v1 -c gerente $1 $BRANCH.1 | wc -l) # Quantidade de ip de rotas conhecidas

# Imprime o cabeçalho da tabela
echo "\nIpRouteDest \t| Interface \t| NextHop \t| Type \t| Proto \t| Mask"
echo "--------------------------------------------------------------------------------"

# Para cada ip de rota conhecida, são feitas requisições das informações necessárias para o preencimento da tabela
for i in $(seq $IPs_route)
do
	# Seleciona um ip de rota conhecida de acordo com o índice i
	IPDEST=$(snmpwalk -v1 -c gerente $1 $BRANCH.1 | sed -n $i'p' | cut -d ' ' -f 4)

	# Requisita o index da interface da rota (ipRouteIfIndex)
	INDEX=$(snmpget -v1 -c gerente $1 $BRANCH.2.$IPDEST | cut -d ' ' -f 4)

	# Com esse index, pelo objeto "interfaces", pega o nome da interface
	INTERFACE=$(snmpget -v1 -c gerente $1 iso.3.6.1.2.1.2.2.1.2.$INDEX | cut -d ' ' -f 4)

	# Requisita o próximo salto da rota (ipRouteNextHop)
	NHOP=$(snmpget -v1 -c gerente $1 $BRANCH.7.$IPDEST | cut -d ' ' -f 4)

	# Requisita o tipo da rota (ipRouteType)
	TYPE=$(snmpget -v1 -c gerente $1 $BRANCH.8.$IPDEST | cut -d ' ' -f 4)

	# Requisita o mecanismo utilizado para aprender a rota (ipRouteProto)
	PROTO=$(snmpget -v1 -c gerente $1 $BRANCH.9.$IPDEST | cut -d ' ' -f 4)

	# Requisita a mácara da rede (ipRouteMask)
	MASK=$(snmpget -v1 -c gerente $1 $BRANCH.11.$IPDEST | cut -d ' ' -f 4)

	# Imprime os valores na terminal
	echo "$IPDEST \t| $INTERFACE \t| $NHOP \t| $TYPE \t| $PROTO \t| $MASK"
 
done