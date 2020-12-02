#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCor05A03  บAutor  ณMarcelo Franca      บ Data ณ  13/11/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Incluir Numero de Serie - Status mudar para Faturar        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็ใo ณ 06/02/2020, Mแrio Augusto Cavenaghi - EthosX:              บฑฑ
ฑฑบ          ณ             Corre็ใo ERROR.LOG                             บฑฑ
ฑฑบ          ณ 07/02/2020, Descontinuado o campo C5_XDESTAT               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function COR05A03()

	Local oListadlg
	Local cId       := SuperGetMV("3C_USRFAT",, "000000")
	Local alSize    := MsAdvSize(.F., .T.)
	Local alObjects := {}
	Local alInfo    := {}
	Local alPosObj  := {}
	Local alHeader  := {}
	Local nX        := 1
	Local nRecSC6   := 0

	Private oVendas
	Private oGetDados
	Private nOpca    := 0
	Private nlGetLin := 0
	Private cItem    := ""
	Private cGrupo   := ""
	Private cTpcarga := ""
	Private cRetoper := ""
	Private aColsLoc := {}
	Private dDataLib := dDataBase

	Default oMainWnd := NIL

	If __cUserID $ cId //Verifica ID do Usuario para alteracao do status
		If SC5->C5_XSTATUS <> '03'
			Alert("Pedido deve estar no Status  - LIBERADO P/ SEPARAวรO !!!")
			Return()
		EndIf

		//Fazer tela para incluir o numero de serie nos itens
		SB1->(DbSetOrder(1))
		SC6->(DbSetOrder(1))
		SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))
		While SC6->(!EOF()) .And. SC6->C6_NUM == SC5->C5_NUM
			SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODUTO))
			If SB1->B1_LOCALIZ = 'S'
				For nX := 1 To SC6->C6_QTDVEN
					If nX = 1
						cItem   := SC6->C6_ITEM
						nRecSC6 := SC6->(Recno())
					Else
						cItem := SOMA1(cItem)
						While SC6->(dbSeek(xFilial() + SC5->C5_NUM + cItem))
							cItem := SOMA1(cItem)
						Enddo
						SC6->(dbGoto(nRecSC6))
						If aScan(aColsLoc, {|x| x[1] == cItem}) > 0
							cItem := SOMA1(cItem)
						Endif
					EndIf
					aAdd(aColsLoc, { ;
					cItem,;
					SC6->C6_PRODUTO,;
					SC6->C6_DESCRI,;
					SC6->C6_NUMSERI,;
					SC6->C6_UM,;
					SC6->C6_PRCVEN,;
					SC6->C6_TES,;
					SC6->C6_LOCAL,;
					SC6->C6_CF,;
					SC6->C6_CLI,;
					SC6->C6_ENTREG,;
					SC6->C6_LOJA,;
					SC6->C6_NUM,;
					SC6->C6_DESCRI,;
					SC6->C6_CLASFIS,;
					SC6->C6_TPOP,;
					SC6->C6_SUGENTR,;
					SC6->C6_INTROT,;
					SC6->C6_RATEIO,;
					SC6->C6_TPPROD,;
					SC6->C6_XKIT,;
					SC6->C6_XPRCANT,;
					.F.})
				Next
			EndIf
			SC6->(DbSkip())
		Enddo
		If Empty(aColsLoc)
			Alert("No Pedido nใo existe Produto com LOCALIZAวรO !")
			nOpca := 2
		Else
			AAdd(alObjects, {1, 120, .T., .F.})
			alInfo := {alSize[1], alSize[2], alSize[3], alSize[4], 3, 3}
			alPosObj := MsObjSize(alInfo, alObjects)

			aAdd(alHeader,{"ITEM"          , "ITEM"     , "@!"              ,002, 000, "AllwaysTrue()", "๛", "C", ""})
			aAdd(alHeader,{"PRODUTO"       , "PRODUTO"  , "@!"              ,015, 000, "AllwaysTrue()", "๛", "N", ""})
			aAdd(alHeader,{"DESCRICAO"     , "DESCRICAO", "@!"              ,030, 000, "AllwaysTrue()", "๛", "N", ""})
			Aadd(alHeader,{"NUMERO SERIE"  , "NUMSERI"  , "@!"              ,020, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"UM"            , "UM"       , "@!"              ,002, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"PRECO UNITARIO", "UNITARIO" , "@E 99,999,999.99",011, 002, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"TES"           , "TES"      , "@!"              ,003, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"LOCAL"         , "LOCAL"    , "@!"              ,002, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"CF"            , "CF"       , "@!"              ,005, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"CLIENTE"       , "CLIENTE"  , "@!"              ,006, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"ENTREG"        , "ENTREG"   , "@D"              ,008, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"LOJA"          , "LOJA"     , "@!"              ,004, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"PEDIDO"        , "PEDIDO"   , "@!"              ,006, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"DESCRI"        , "DESCRI"   , "@!"              ,120, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"CLASFIS"       , "CLASFIS"  , "@!"              ,003, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"TIPO OP"       , "TIPOOP"   , "@!"              ,001, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"SUGENTR"       , "SUGENTR"  , "@d"              ,008, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"INTROT"        , "INTROT"   , "@!"              ,001, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"RATEIO"        , "RATEIO"   , "@!"              ,001, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"TPPROD"        , "TPPROD"   , "@!"              ,001, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"KIT"           , "KIT"      , "@!"              ,001, 000, "AllwaysTrue()", "๛", "C", ""})
			Aadd(alHeader,{"PRECO ANTERIOR", "ANTERIOR" , "@E 99,999,999.99",011, 002, "AllwaysTrue()", "๛", "C", ""})

			//Inicio da Montagem da Tela
			Define MsDialog oListadlg Title OemToAnsi("Pedido de Venda ") + SC5->C5_NUM From alSize[7], 0 To alSize[6] + 70, alSize[5] Of oMainWnd Pixel

			@ 042, 007 LISTBOX oVendas FIELDS HEADER ;
			"ITEM"     ,;
			"PRODUTO"  ,;
			"DESCRICAO",;
			"NUMSERI"  ,;
			"UM"       ,;
			"UNITARIO" ,;
			"TES"      ,;
			"LOCAL"    ,;
			"CF"       ,;
			"CLIENTE"  ,;
			"ENTREG"   ,;
			"LOJA"     ,;
			"PEDIDO"   ,;
			"DESCRI"   ,;
			"CLASFIS"  ,;
			"TIPOOP"   ,;
			"SUGENTR"  ,;
			"INTROT"   ,;
			"RATEIO"   ,;
			"TPPROD"   ,;
			"KIT"      ,;
			"ANTERIOR" ,;
			SIZE 300, 70 ON DBLCLICK () OF oListadlg PIXEL

			oGetDados := MSNewGetDados():New(alPosObj[1, 1], alPosObj[1, 2], alPosObj[1, 3], alPosObj[1, 4], GD_UPDATE, "AllwaysTrue()", "AllwaysTrue()",, {"NUMSERI"},, "@!",,,,, @alHeader, @aColsLoc)
			oGetDados:lInsert := .F.

			oVendas:SetArray(aColsLoc)
			oVendas:bLine := {|| { ;
			aColsLoc[oVendas:nAt,  1], aColsLoc[oVendas:nAt,  2],;
			aColsLoc[oVendas:nAt,  3], aColsLoc[oVendas:nAt,  4],;
			aColsLoc[oVendas:nAt,  5], aColsLoc[oVendas:nAt,  6],;
			aColsLoc[oVendas:nAt,  7], aColsLoc[oVendas:nAt,  8],;
			aColsLoc[oVendas:nAt,  9], aColsLoc[oVendas:nAt, 10],;
			aColsLoc[oVendas:nAt, 11], aColsLoc[oVendas:nAt, 12],;
			aColsLoc[oVendas:nAt, 13], aColsLoc[oVendas:nAt, 14],;
			aColsLoc[oVendas:nAt, 15], aColsLoc[oVendas:nAt, 16],;
			aColsLoc[oVendas:nAt, 17], aColsLoc[oVendas:nAt, 18],;
			aColsLoc[oVendas:nAt, 19], aColsLoc[oVendas:nAt, 20],;
			aColsLoc[oVendas:nAt, 21], aColsLoc[oVendas:nAt, 22]}}

			nlGetLin := alPosObj[1, 3] + 5
			@ nlGetLin, alPosObj[1, 4] - 90 BmpButton Type 1 Action (nOpca := 2, Close(oListadlg))
			@ nlGetLin, alPosObj[1, 4] - 60 BmpButton Type 2 Action (nOpca := 1, Close(oListadlg))
			MissBox(oVendas, aColsLoc)
			ACTIVATE MSDIALOG oListadlg CENTERED ON INIT oVendas:Refresh()
		Endif
		If nOpca == 2
			If !Empty(aColsLoc)
				BEGIN TRANSACTION
					Processa({|| GraSC69()}, "Grava็ใo do N๚mero de S้rie")
				END TRANSACTION
			Endif
			If U_Cor05A01()
				If MSGYESNO("Alterar status do Pedido de Venda = " + SC5->C5_NUM + " para - LIBERADO P/ FATURAMENTO ?")
					SC5->(Reclock("SC5", .F.))
					SC5->C5_XSTATUS := "04"
					//SC5->C5_XDESTAT := "LIBERADO P/ FATURAMENTO"
					SC5->C5_BLQ     := '4'
					SC5->(MsUnLock())

					SC9->(DbSetOrder(1))
					SC9->(DbSeek(xFilial("SC9") + SC5->C5_NUM))
					While SC9->C9_PEDIDO == SC5->C5_NUM
						SC9->(Reclock("SC9", .F.))
						SC9->C9_XBLQ := "X"
						SC9->(MsUnLock())
						SC9->(DbSkip())
					Enddo
				EndIf
			EndIf
		EndIf

	Else
		Alert("Usuแrio sem permissใo de acesso !!!")
	EndIf

Return()


/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ MissBox      ณ Autor ณ Vendas Clientes   ณ Data ณ 02/08/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Retorna o vetor com as colunas do ListBox.      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpO1 = Objeto utilizado no listbox de Vendas        ณฑฑ
ฑฑณ          ณ ExpA1 = Array com o as linhas sintehticas ou analiticas.   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ LOJC080                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MissBox(oListBox, aTotal)

	If Len(aTotal) <> 0
		oListBox:SetArray(aTotal)
		oListBox:bLine := {|| {;
		aTotal[oListBox:nAt,  1], aTotal[oListBox:nAt,  2],;
		aTotal[oListBox:nAt,  3], aTotal[oListBox:nAt,  4],;
		aTotal[oListBox:nAt,  5], aTotal[oListBox:nAt,  6],;
		aTotal[oListBox:nAt,  7], aTotal[oListBox:nAt,  7],;
		aTotal[oListBox:nAt,  9], aTotal[oListBox:nAt, 10],;
		aTotal[oListBox:nAt, 11], aTotal[oListBox:nAt, 12],;
		aTotal[oListBox:nAt, 13], aTotal[oListBox:nAt, 14],;
		aTotal[oListBox:nAt, 15], aTotal[oListBox:nAt, 16],;
		aTotal[oListBox:nAt, 17], aTotal[oListBox:nAt, 18],;
		aTotal[oListBox:nAt, 13], aTotal[oListBox:nAt, 20],;
		aTotal[oListBox:nAt, 21], aTotal[oListBox:nAt, 22],;
		.F.}}
	Endif

Return


//=================================================================================================
Static Function GraSC69()

	Local nLinha:= 1

	ProcRegua(Len(oGetDados:Acols))
	SC9->(DbSetOrder(1))
	For nLinha := 1 To Len(oGetDados:Acols)
		IncProc("Gravando Numero de S้rie")
		If SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM + oGetDados:Acols[nLinha, 1] + oGetDados:Acols[nLinha, 2]))
			SC6->(Reclock("SC6", .F.))
			SC6->C6_QTDVEN  := 1
			SC6->C6_QTDEMP  := 1
			SC6->C6_VALOR   := SC6->C6_PRCVEN
			SC6->C6_NUMSERI := oGetDados:Acols[nLinha, 4]
			SC6->(MsUnLock())

			If SC9->(DbSeek(xFilial("SC9") + SC5->C5_NUM + oGetDados:Acols[nLinha, 1] + "01" + oGetDados:Acols[nLinha, 2]))
				SC9->(Reclock("SC9", .F.))
				SC9->C9_QTDLIB  := 1
				SC9->C9_NUMSERI := oGetDados:Acols[nLinha, 4]
				dDataLib := SC9->C9_DATALIB
				cGrupo   := SC9->C9_GRUPO
				cTpcarga := SC9->C9_TPCARGA
				cRetoper := SC9->C9_RETOPER
				SC9->(MsUnLock())
			EndIf

		Else
			SC6->(Reclock("SC6", .T.))
			SC6->C6_FILIAL  := SC5->C5_FILIAL
			SC6->C6_ITEM    := oGetDados:Acols[nLinha,  1]
			SC6->C6_PRODUTO := oGetDados:Acols[nLinha,  2]
			SC6->C6_DESCRI  := oGetDados:Acols[nLinha,  3]
			SC6->C6_NUMSERI := oGetDados:Acols[nLinha,  4]
			SC6->C6_UM      := oGetDados:Acols[nLinha,  5]
			SC6->C6_PRCVEN  := oGetDados:Acols[nLinha,  6]
			SC6->C6_TES     := oGetDados:Acols[nLinha,  7]
			SC6->C6_LOCAL   := oGetDados:Acols[nLinha,  8]
			SC6->C6_CF      := oGetDados:Acols[nLinha,  9]
			SC6->C6_CLI     := oGetDados:Acols[nLinha, 10]
			SC6->C6_ENTREG  := oGetDados:Acols[nLinha, 11]
			SC6->C6_LOJA    := oGetDados:Acols[nLinha, 12]
			SC6->C6_NUM     := oGetDados:Acols[nLinha, 13]
			SC6->C6_DESCRI  := oGetDados:Acols[nLinha, 14]
			SC6->C6_CLASFIS := oGetDados:Acols[nLinha, 15]
			SC6->C6_TPOP    := oGetDados:Acols[nLinha, 16]
			SC6->C6_SUGENTR := oGetDados:Acols[nLinha, 17]
			SC6->C6_INTROT  := oGetDados:Acols[nLinha, 18]
			SC6->C6_RATEIO  := oGetDados:Acols[nLinha, 19]
			SC6->C6_TPPROD  := oGetDados:Acols[nLinha, 20]
			SC6->C6_XKIT    := oGetDados:Acols[nLinha, 21]
			SC6->C6_XPRCANT := oGetDados:Acols[nLinha, 22]
			SC6->C6_VALOR   := SC6->C6_PRCVEN
			SC6->C6_QTDVEN  := 1
			SC6->C6_QTDEMP  := 1
			SC6->(MsUnLock())

			SC9->(Reclock("SC9", .T.))
			SC9->C9_FILIAL  := SC5->C5_FILIAL
			SC9->C9_ITEM    := oGetDados:Acols[nLinha,  1]
			SC9->C9_PRODUTO := oGetDados:Acols[nLinha,  2]
			SC9->C9_NUMSERI := oGetDados:Acols[nLinha,  4]
			SC9->C9_PRCVEN  := oGetDados:Acols[nLinha,  6]
			SC9->C9_LOCAL   := oGetDados:Acols[nLinha,  8]
			SC9->C9_CLIENTE := oGetDados:Acols[nLinha, 10]
			SC9->C9_DATENT  := oGetDados:Acols[nLinha, 11]
			SC9->C9_LOJA    := oGetDados:Acols[nLinha, 12]
			SC9->C9_PEDIDO  := oGetDados:Acols[nLinha, 13]
			SC9->C9_TPOP    := oGetDados:Acols[nLinha, 16]
			SC9->C9_DATALIB := dDataLib
			SC9->C9_TPCARGA := cTpcarga
			SC9->C9_RETOPER := cRetoper
			SC9->C9_GRUPO   := cGrupo
			SC9->C9_SEQUEN  := "01"
			SC9->C9_QTDLIB  := 1
			SC9->(MsUnLock())
		EndIf
	Next

Return
