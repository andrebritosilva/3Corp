#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#Include "RwMake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Cor05A02  �Autor  �Marcelo Franca      � Data �  01/12/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Alteracao de Status para Separacao - verifica ID           ���
�������������������������������������������������������������������������͹��
���Altera��o � 07/02/2020, M�rio Augusto Cavenaghi - EthosX:              ���
���          �             Descontinuado o campo C5_XDESTAT               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function COR05A02()

Local cId	:= SuperGetMV("3C_USRSEP", ,"000000")

If __cUserID $ cId //Verifica ID do Usuario para alteracao do status

	If SC5->C5_XSTATUS <> '02'

		Alert("Pedido deve estar no Status  - PEDIDO LIBERADO !!!")
		Return()

	EndIf

	If Select("TMPSC9") > 0
		DbSelectArea("TMPSC9")
		TMPSC9->(DbCloseArea())
	EndIf

	cQuery:= " SELECT * FROM " + RetSqlName("SC9") + " SC9  "
	cQuery+= " WHERE SC9.C9_PEDIDO = '" + SC5->C5_NUM + "' "
	cQuery+= 	" AND SC9.C9_FILIAL = '" + SC5->C5_FILIAL + "' "
	cQuery+= 	" AND (SC9.C9_BLCRED IN ('01','04','05') "
	cQuery+= 	" OR SC9.C9_BLEST IN ('02','03') ) "
	cQuery+= 	" AND SC9.D_E_L_E_T_=' ' "

	DbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"TMPSC9",.F.,.T.)

	DbSelectArea("TMPSC9")
	TMPSC9->(DbGotop())

	If TMPSC9->(!EOF())
		Alert("Pedido bloqueado por estoque/cr�dito  !!!")
		Return()
	EndIf

	TMPSC9->(DbCloseArea())

	If MSGYESNO("Alterar status do Pedido de Venda = " + SC5->C5_NUM + " para - LIBERADO P/ SEPARA��O ?")

		SC5->(Reclock("SC5",.F.))
		SC5->C5_XSTATUS	:= "03"
		//SC5->C5_XDESTAT := "LIBERADO P/ SEPARA��O"
		SC5->C5_BLQ := '3'
		SC5->(MsUnLock())

	EndIf

Else

	Alert("Usu�rio sem permiss�o de acesso !!!")

EndIf

Return()