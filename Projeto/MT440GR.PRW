#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT440GR   �Autor  �Marcelo Franca      � Data �  26/11/19   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
�������������������������������������������������������������������������͹��
���Altera��o � 07/02/2020, M�rio Augusto Cavenaghi - EthosX:              ���
���          �             Descontinuado o campo C5_XDESTAT               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT440GR()

	Local nOpcao	:= PARAMIXB[1]
	Local nX		:= 1
	Local nPosTes	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"})
	Local lEst		:= .F.

	If nOpcao = 1 .And. M->C5_TIPO == "N"

		SF4->(DbSetOrder(1))

		For nX:= 1 To Len(aCols)

			If SF4->(DbSeek(xFilial("SF4") + aCols[nX][nPosTes]) )  .And. SF4->F4_ESTOQUE == "S"

				lEst:= .T.

		    EndIf

		Next nX

		If lEst

			M->C5_XSTATUS	:= "02"
			//M->C5_XDESTAT 	:= "PEDIDO LIBERADO"
			M->C5_BLQ 		:= ' '

		Else

			M->C5_XSTATUS	:= "04"
			//M->C5_XDESTAT 	:= "LIBERADO P/ FATURAMENTO"
			M->C5_BLQ 		:= ' '

		EndIf

	ElseIf M->C5_TIPO <> "N"

		M->C5_XSTATUS	:= "04"
		//M->C5_XDESTAT 	:= "LIBERADO P/ FATURAMENTO"
		M->C5_BLQ 		:= '4'

	EndIf

Return(.T.)