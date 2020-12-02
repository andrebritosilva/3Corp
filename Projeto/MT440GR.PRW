#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT440GR   ºAutor  ³Marcelo Franca      º Data ³  26/11/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteração ³ 07/02/2020, Mário Augusto Cavenaghi - EthosX:              º±±
±±º          ³             Descontinuado o campo C5_XDESTAT               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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