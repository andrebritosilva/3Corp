#include 'protheus.ch'
#include 'parmtype.ch'

User Function 1DupPref()

Local aArea    := GetArea()
Local aAreaSE1 := SE1->(GetArea())
Local cPrefixo := SubStr(AllTrim(xFilial('SF2')+SE1->E1_SERIE),1,3)

dbSelectArea('SE1')

dbSetOrder(1)

While MsSeek(xFilial('SE1')+cPrefixo+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO) .And. aAreaSE1[3] <> SE1->(RecNo())

	cPrefixo : Soma1(cPrefixo)

EndDo

RestArea(aAreaSE1)

RestArea(aArea)

Return(cPrefixo)