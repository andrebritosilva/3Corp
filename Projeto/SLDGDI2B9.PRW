/*================================================================================================
{Protheus.doc} SLDGDI2B9
Inclui Saldos Iniciais dos Produtos
@Project IMPLANTAÇÃO
@Author  Mário Augusto Cavenaghi
@Since   30/01/2020
@Type    User Function
@Return  Nil
@Version P12.1.25
@History
================================================================================================*/

#INCLUDE "TOTVS.CH"

User Function SLDGDI2B9()

	Processa({|| PROCIMP()}, "Atualizando Saldos Iniciais dos Produtos...")

Return


/*================================================================================================
Efetua a inclusão de Saldos iniciais dos Produtos
*/
Static Function PROCIMP

	Local cBuffer   := ""
	Local cArqLog   := ""
	Local cPerg     := "SLDGDI2B9"
	Local cLog      := "Filial;	Produto" + CRLF
	Local lGrvLog   := .F.
	Local aField    := {}
	Local aData     := {}
	Local nLin      := 0
	Local nHandle   := 0
	Local nProduto  := 0
	Local nProdGDI  := 0
	Local nFilial   := 0
	Local nArmazem  := 0
	Local nQtdIni   := 0
	Local nVlrUni   := 0
	Local nSldIni   := 0

	CRIASX1(cPerg)
	If Pergunte(cPerg)
		ConOut(FunName() + " -> Processando arquivo: " + MV_PAR01)
		nHandle := FT_FUSE(MV_PAR01)	//	Abre Arquivo
		If nHandle > 0	//	Abriu o arquivo
			cBuffer := FT_FREADLN()
			aField := StrTokArr2(cBuffer, ";", .T.)	//	Monta o Cabeçalho
			nLin := 0

			// As Colunas "FILIAL" e "TP_PART", não são usadas pode excluir da estrutura do .CSV
			nProduto := aScan(aField, {|x| x == "B1_COD"})
			nProdGDI := aScan(aField, {|x| x == "B1_XCODGDI"})
			nFilial  := aScan(aField, {|x| x == "B9_FILIAL"})
			nArmazem := aScan(aField, {|x| x == "B9_LOCAL"})
			nQtdIni  := aScan(aField, {|x| x == "B9_QINI"})
			nVlrUni  := aScan(aField, {|x| x == "B9_CM1"})
			nSldIni  := aScan(aField, {|x| x == "B9_VINI1"})

			FT_FSKIP()
			While !FT_FEOF()
				cBuffer := FT_FREADLN()
				IF Empty(cBuffer)
					Exit
				EndIf
				cBuffer := StrTran(cBuffer, ",", ".")	//	Substiui a ',' nos decimais por '.'
				aAdd(aData, StrTokArr2(cBuffer, ";", .T.))	//	Monta os Itens
				nLin++
				FT_FSKIP()
			EndDo
			FT_FUSE()	//	Fecha o Arquivo
			Iif(Select("SB1") == 0, ChkFile("SB1"),)
			SB1->(dbSetOrder(1))	//	B1_FILIAL+B1_COD
			Iif(Select("SB9") == 0, ChkFile("SB9"),)
			SB9->(dbSetOrder(1))	//	B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
			ProcRegua(nLin)
			For nLin := 1 To Len(aData)
				IncProc("Produto... " + aData[nLin, nProduto])
				If SB1->(dbSeek(xFilial() + aData[nLin, nProduto]))
					RecLock("SB1")
					SB1->B1_FILIAL  := xFilial("SB1")
					SB1->B1_XCODGDI := aData[nLin, nProdGDI]
					SB1->(msUnLock())
					If SB9->(dbSeek(aData[nLin, nFilial] + SB1->B1_COD + aData[nLin, nArmazem] + DtoS(MV_PAR02)))
						RecLock("SB9", .F.)
					Else
						RecLock("SB9", .T.)
						SB9->B9_FILIAL := aData[nLin, nFilial]
						SB9->B9_COD    := SB1->B1_COD
						SB9->B9_LOCAL  := aData[nLin, nArmazem]
						SB9->B9_DATA   := MV_PAR02
						SB9->B9_MCUSTD := "1"
					Endif
					SB9->B9_QINI  := Val(aData[nLin, nQtdIni])
					SB9->B9_CM1   := Val(aData[nLin, nVlrUni])
					SB9->B9_VINI1 := SB9->B9_QINI * SB9->B9_CM1
					SB9->(msUnLock())
				Else
					lGrvLog := .T.
					cLog += aData[nLin, nFilial] + ";	" + aData[nLin, nProduto] + CRLF
				Endif
			Next
		Else
			Alert("Não foi possível abrir o arquivo")
		EndIf
		If lGrvLog
			cArqLog := Alltrim(StrTran(MV_PAR01, ".csv", ".log"))
			MemoWrite(cArqLog, cLog) //	Grava o LOG das contas não migradas
			EECVIEW(cLog, "Produtos não cadastrados")	//	Visualiza o LOG
			Alert("Esse log foi salvo em " + cArqLog)
		Endif
	EndIf

Return


/*================================================================================================
Cria Pergunta
*/
Static Function CRIASX1(cPerg)

	Local cF3 := PadR("SLDGDI2B9", Len(SXB->XB_ALIAS))
	Local nLinha := nColuna := 0
	Local aPerg := {}

	aAdd(aPerg, {"X1_ORDEM", "X1_PERGUNT"          , "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_GSC", "X1_F3", "X1_VAR01", "X1_CNT01" })
	aAdd(aPerg, {"01"      , "Caminho dos Arquivos", "MV_CH1"    , "C"      , 60          , "G"     , cF3    , "MV_PAR01", "\"        })
	aAdd(aPerg, {"02"      , "Data Saldo Inicial"  , "MV_CH2"    , "D"      , 08          , "G"     , ""     , "MV_PAR02", "dDataBase"})

	// Cria Perguntas
	cPerg := PadR(cPerg, Len(SX1->X1_GRUPO))
	SX1->(DbsetOrder(1))
	For nLinha := 2 To Len(aPerg)
		If !SX1->(dbSeek(cPerg + aPerg[nLinha, 1]))
			Reclock("SX1", .T.)
			SX1->X1_GRUPO := cPerg
			For nColuna := 1 To Len(aPerg[1])
				SX1->(FieldPut(FieldPos(aPerg[1, nColuna]), aPerg[nLinha, nColuna]))
			Next
			SX1->(MsUnlock())
		Endif
	Next

	// Cria Consulta F3 da Pergunta
	If !SXB->(dbSeek(cF3 + "1"))
		RecLock("SXB", .T.)
		SXB->XB_ALIAS  := cF3
		SXB->XB_TIPO   := "1"
		SXB->XB_SEQ    := "01"
		SXB->XB_COLUNA := "RE"
		SXB->XB_DESCRI := "Caminho dos Arquivos"
		SXB->XB_CONTEM := "SB9"
		SXB->(msUnLock())
	EndIf
	If !SXB->(dbSeek(cF3 + "2"))
		RecLock("SXB", .T.)
		SXB->XB_ALIAS  := cF3
		SXB->XB_TIPO   := "2"
		SXB->XB_SEQ    := "01"
		SXB->XB_COLUNA := "01"
		SXB->XB_CONTEM := "U_GETARQ()"
		SXB->(msUnLock())
	EndIf
	If !SXB->(dbSeek(cF3 + "5"))
		RecLock("SXB", .T.)
		SXB->XB_ALIAS  := cF3
		SXB->XB_TIPO   := "5"
		SXB->XB_SEQ    := "01"
		SXB->XB_CONTEM := "NIL"
		SXB->(msUnLock())
	Endif

Return


/*================================================================================================
Seleciona Caminho dos arquivos
*/
User Function GetArq

	Local cMascara  := "*.csv"
	Local cTitulo   := "Selecione o arquivo"
	Local nMascpad  := 0
	Local cDirini   := ""
	Local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/
	Local nOpcoes   := GETF_LOCALHARD
	Local lArvore   := .T. /*.T. = apresenta o árvore do servidor || .F. = não apresenta*/

	//MV_PAR01 := cGetFile("*.*", "Selecione uma pasta", 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T.)
	MV_PAR01 := cGetFile(cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)

Return(.T.)
