//=================================================================================================
//	Ponto de Entrada na gravação dos Itens da Nota
//	Usado para gravar as Observações dos Pedidos na Nota

#INCLUDE "TOTVS.CH"

Static _cPedido := ""

User Function MSD2460

	Local lLockSF2 := .F.

	If _cPedido <> SC5->C5_NUM
		lLockSF2 := Reclock("SF2")
		SF2->F2_XOBS := Alltrim(SF2->F2_XOBS + CRLF + SC5->C5_XOBS)	//	Concatena todos os Pediddos
		If lLockSF2
			SF2->(msUnLock())
		Endif
		_cPedido := SC5->C5_NUM
	Endif

RETURN
