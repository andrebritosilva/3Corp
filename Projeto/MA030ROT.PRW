#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMA030ROT  บAutor  ณMarcelo - Ethosx    บ Data ณ  18/11/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto-de-Entrada: MA030ROT - Inclusใo de novas rotinas     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Ap๓s a cria็ใo do aRotina, para adicionar novas rotinas    บฑฑ
ฑฑบ          ณao programa.                                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Para adicionar mais rotinas, adicionar mais subarrays ao   บฑฑ
ฑฑบ          ณarray. No advanced este n๚mero ้ limitado.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Deve se retornar um array onde cada subarray ้ uma linha a บฑฑ
ฑฑบ          ณser adicionada ao aRotina padrใo.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 3Corp                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MA030ROT()

Local aRetorno:= {}

Aadd(aRetorno,{'Incluir Fornecedor'	,'Processa({|| U_Cor05A04()},"Incluir Fornecedor")'	,0	,2	,NIL})

Return(aRetorno)