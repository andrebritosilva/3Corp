#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"        
#include "fivewin.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบ Programa  ณ IMPORTFOR                              บ Data ณ 06/11/2019 บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบ Autor     ณ Marcelo - Ethosx                                           บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Descricao ณ Rotina para a importa็ใo dos Fornecedores do template CSV  บฑฑ
ฑฑบ           ณ para o ERP Protheus.                                       บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe   ณ IMPORTFOR()                                                บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno   ณ nil                                                        บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso       ณ 3Corp                                                      บฑฑ
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 

User Function IMPORTFOR()

Local aArea		:= GetArea()
Local lConv     := .F.

Private cArquivo := Space(150)
Private lOk      :=.F.
Private bOk      := { || If(ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
Private bCancel  := { || lOk:=.F.,oDlg:End() }
Private lEnd     := .F.
Private aLog    := {}

Define MsDialog oDlg Title "Importa็ใo de Fornecedores" From 08,15 To 25,120 Of GetWndDefault()
      
@ 45,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
@ 45,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
@ 45,275 Button "…" 			Size 010,10 Action Eval({|| cArquivo:=SelectFile() }) Of oDlg Pixel

Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

If lOk
	oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpForCSV(cArquivo, @lEnd)}, "Importa็ใo de Fornecedores", "Processando arquivo de Fornecedores", .F. )
	oProcess:Activate()
	If lConv
		// cria arquivo de LOG
		CRIALOG(aLog, SUBSTR(cArquivo,1,LEN(cArquivo)-4), 5)
		// gera arquivo excel 
		//u_GeraExcel(aErros, SUBSTR(cArq,1,LEN(cArq)-4))
	EndIf
EndIf

RestArea(aArea)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบ Programa  ณ IMPFORCSV                              บ Data ณ 06/11/2019 บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบ Autor     ณ Marcelo - Ethosx                                           บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Descricao ณ Rotina para a importa็ใo dos Fornecedores do template CSV  บฑฑ
ฑฑบ           ณ para o ERP Protheus.                                       บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe   ณ IMPFORCSV(cArq, lEnd)                                      บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno   ณ Logico                                                     บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso       ณ 3Corp                                                      บฑฑ
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function ImpForCSV(cArquivo, lEnd)

Local aVetor   := {}
Local aDados   := {}
Local aArea	   := GetArea()
Local cLinha
Local nTot     := 0
Local nCont    := 1
Local nAtual   := 0
Local nTimeIni := 0
Local nLinTit  := 1  // Total de linhas do Cabe็alho
Local aCampos  := {} 
Local cCgc		:= ""
Local cCodigo	:= ""
Local cLoja		:= ""
Local lGrava	:= .T.
Local nPosNom  	:= 0
Local nPosCgc   := 0
Local nPosCod   := 0
Local nPosDes   := 0
Local nPosLoj	:= 0
Local cTipo		:= ""
Local cNomArqErro := ""
Local cErroTemp	:= ""
Local nLinhas	:= 0
Local cBuffer	:= ""
Local cCampo	:= ""
Local cDescErro	:= ""
Local cConteudo	:= ""
Local nErrLin	:= 0
Local lOpErro	:= .F.
Local lErro		:= .F.
Local X			:= 1
Local nHandle	:= 0

Private lMsErroAuto := .F.
Private cPath       := SubStr(cArquivo,1,RAT("\", cArquivo))

If (nHandle := FT_FUse(AllTrim(cArquivo)))== -1
	Help(" ",1,"NOFILEIMPOR")
	RestInter()
	Return .F.
EndIf

nTot := FT_FLASTREC()

FT_FGOTOP()

// Tratamento do cabe็alho
While nLinTit > 0 .AND. !Ft_FEof()
   cLinha := FT_FREADLN()

   If LEN(cLinha) == 1023
		FT_FSKIP()
		cConLinha := FT_FREADLN()

		While LEN(cConLinha) == 1023
			cLinha += cConLinha
			FT_FSKIP()
			cConLinha := FT_FREADLN()
		EndDo

		cLinha += cConLinha

	EndIf

	If nLinTit == 1
		aCampos := SEPARA(cLinha,";",.T.)
		cLinha += ";DESC. ERRO"
	EndIf

	cLinha := ""
	Ft_FSkip()
	nLinTit--

EndDo

oProcess:SetRegua1( nTot )
oProcess:SetRegua2( int(ntot/100) )

// Processa os dados do template
Do While !FT_FEOF()
	oProcess:IncRegua1("Registros processados : " + ALLTRIM(STR(nCont)) )
	aVetor := {}
	cLinha := FT_FREADLN()
	
	If lEnd
		MsgInfo("Importa็ใo cancelada!","Fim")
		Return .F.
	Endif
	
	nAtual++
	If (nAtual % 100) = 1
		nTimeIni := Seconds()
	EndIf
	If (nAtual % 100) = 0
		oProcess:IncRegua2( "Tempo Restante - (" + EstTime(ntot,nAtual,(nAtual-100),nTimeIni) + ")" )
	EndIf
	
	If LEN(cLinha) == 1023
		FT_FSKIP()
		cConLinha := FT_FREADLN()
		While LEN(cConLinha) == 1023
			cLinha += cConLinha
			FT_FSKIP()
			cConLinha := FT_FREADLN()
		EndDo
		cLinha += cConLinha
	EndIf
	
	nAtual++
	If (nAtual % 100) = 1
		nTimeIni := Seconds()
	EndIf
	If (nAtual % 100) = 0
		oProcess:IncRegua2( "Tempo Restante - (" + EstTime(ntot,nAtual,(nAtual-100),nTimeIni) + ")" )
	EndIf

	aDados := SEPARA(cLinha,";",.T.) // A fun็ใo SEPARA e a fun็ใo STRTOKARR, converte uma string em um array, o SEPARA converte os espa็os em branco 
	
	For X:=1 To LEN(aCampos)

		SX3->(DbSetOrder(2)) 
		SX3->(DbGoTop())

		If SX3->(DbSeek(aCampos[X]))
			cTipo := SX3->X3_TIPO
		EndIf

		Do Case
			Case cTipo == 'D' 
				aDados[X] := CTOD(aDados[X])
			Case cTipo == 'N' 
				aDados[X] := IIf(Empty(aDados[X]),0,VAL(STRTRAN(aDados[X],",",".")))
			Case cTipo == 'M' 
				aDados[X] := IIf(Empty(aDados[X]),"",MSMM(aDados[X]))
		EndCase

		If AllTrim(aCampos[X]) == "A2_COD"
				
			If Empty(aDados[X])
				
				aDados[X]:= GETSXENUM("SA2","A2_COD")
				
			EndIf
			
		EndIf

		If AllTrim(aCampos[X]) == "A2_LOJA"
				
			If Empty(aDados[X])
				
				aDados[X]:= "0001"
			
			EndIf
			
		EndIf

		If AllTrim(aCampos[X]) == "A2_CGC"
				
			cCGC:= AllTrim(aDados[X])
				
		EndIf

		If !Empty(aDados[X])

			AADD(aVetor,{aCampos[X],aDados[X] ,Nil})

		EndIf

	Next X
	
	SA2->(DbSetOrder(3)) // A2_FILIAL + A2_CGC
	SA2->(DbGoTop())	
	
	lGrava:= .T.

	If SA2->(DbSeek(xFilial("SA2") + AllTrim(cCgc) ) )

		nPosNom  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_NOME" })
		nPosCgc  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_CGC" })
		nPosCod  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_COD" })
		nPosDes  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_LOJA" })
		
		AADD(aLog,{"A2_COD"  ,aDados[nPosCod] ,Nil}) // Codigo
		AADD(aLog,{"A2_LOJA" ,aDados[nPosDes] ,Nil}) // Loja
		AADD(aLog,{"A2_NOME" ,aDados[nPosNom] ,Nil}) // Nome
		AADD(aLog,{"A2_CGC"  ,aDados[nPosCgc] ,Nil}) // CNPJ/CPF
		AADD(aLog,{"ERRO" 	 ,"Fornecedor jแ cadastrado - A2_CGC" ,Nil})
		
		lGrava:= .F.
		
		RollBackSx8()

	EndIf

	cCodigo:= ""
	cLoja:= ""

	If SA2->(DbSeek(xFilial("SA2") + AllTrim(SubStr(cCgc,1,8)) ) ) .And. lGrava 

		cCodigo	:= SA2->A2_COD
		cLoja	:= SA2->A2_LOJA
	
		SA2->(DbSetOrder(1))
		SA2->(DbGoTop())
	
		While SA2->(DbSeek(xFilial("SA2") + cCodigo + cLoja ) )
			cLoja := Strzero((Val(cLoja) + 1),4)
		End
  		
  		nPosLoj  := aScan(aVetor,{ |x| x[1] == "A2_LOJA" })
  		aVetor[nPosLoj][2]:= cLoja
  		
  		nPosCod  := aScan(aVetor,{ |x| x[1] == "A2_COD" })
  		aVetor[nPosCod][2]:= cCodigo

	EndIf

	SA2->(DbSetOrder(1))

	If lGrava

		MSExecAuto({|x,y| Mata020(x,y)},aVetor,3) //3- Inclusao, 4- Altera?o, 5- Exclus?
			
	EndiF	
	
	If lMsErroAuto .And. lGrava
	
		cNomArqErro := "ARQLOG.LOG"
		cErroTemp := Mostraerro(cPath, cNomArqErro) 
		nLinhas   := MLCount(cErroTemp) 
		cBuffer   := "" 
		cCampo    := "" 
		cDescErro := ""
		cConteudo := ""
		nErrLin   := 1 
		lOpErro   := .T.
		lErro     := .T.
		cBuffer   := RTrim(MemoLine(cErroTemp,,nErrLin))
		//Carrega o nome do campo 
		While (nErrLin <= nLinhas)
			nErrLin++
			cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin))
			If lErro
				If ALLTRIM(cBuffer) <> ""
					cDescErro += cBuffer+" "
				Else
					lErro := .F.
				EndIf
			EndIf
			If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO")
				cCampo    := cBuffer
				Exit
			EndIf 
		EndDo
		
		FERASE(cPath + cNomArqErro)
		
		nPosNom	:= aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_NOME" })
		nPosCgc := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_CGC" })
		nPosCod := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_COD" })
		nPosDes := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "A2_LOJA" })
		
		AADD(aLog,{"A2_COD" 	,aDados[nPosCod] ,Nil}) // Codigo
		AADD(aLog,{"A2_LOJA" 	,aDados[nPosDes] ,Nil}) // Loja
		AADD(aLog,{"A2_NOME" 	,aDados[nPosNom] ,Nil}) // Razao Social
		AADD(aLog,{"A2_CGC" 	,aDados[nPosCgc] ,Nil}) // CNPJ/CPF
		AADD(aLog,{"ERRO" 	    ,cDescErro + " - " + cCampo ,Nil})
		
		lMsErroAuto := .F.
		
		RollBackSx8()

	ElseIf lGrava
		
		ConfirmSX8()

	Endif
	
	FT_FSKIP()
	nCont++
EndDo

FT_FUSE()

Aviso("Finalizado","Importacao Finalizada - " + IIF(Empty(aLog),"Com Sucesso!!!	", "Verifique Arquivo de Log"),{"Fechar"})

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบ Programa  ณ SELECTFILE                             บ Data ณ 10/07/2015 บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบ Autor     ณ Microsiga                                                  บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Descricao ณ Rotina para selecao de arquivos CSV para importacao        บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe   ณ SELECTFILE()                                               บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno   ณ cArquivo                                                   บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso       ณ Rede Dor Sใo Luiz                                          บฑฑ
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SelectFile()

Local cMaskDir := "Arquivos .CSV (*.CSV) |*.CSV|"
Local cTitTela := "Arquivo para a integracao"
Local lInfoOpen := .T.
Local lDirServidor := .F.
Local cOldFile := cArquivo

cArquivo := cGetFile(cMaskDir,cTitTela,,cArquivo,lInfoOpen, (GETF_LOCALHARD+GETF_NETWORKDRIVE) ,lDirServidor)

If !File(cArquivo)
	MsgStop("Arquivo Nใo Existe!")
	cArquivo := cOldFile
Return .F.
EndIf

Return cArquivo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบ Programa  ณ VALIDADIR                              บ Data ณ 10/07/2015 บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบ Autor     ณ Microsiga                                                  บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Descricao ณ Rotina para validacao do diretorio do arquivos CSV a ser   บฑฑ
ฑฑบ           ณ importado.                                                 บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe   ณ VALIDADIR(cArquivo)                                        บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno   ณ Logico                                                     บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso       ณ Rede Dor Sใo Luiz                                          บฑฑ
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidaDir(cArquivo)
Local lRet := .T.

If Empty(cArquivo)
	MsgStop("Selecione um arquivo","Aten็ใo")
	lRet := .F.
ElseIf !File(cArquivo)
	MsgStop("Selecione um arquivo vแlido!","Aten็ใo")
	lRet := .F.
EndIf

Return lRet


// ###########################################################################################
// Projeto:
// Modulo :
// Fun็ใo : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 20/03/2015 | Miqueias Dernier  | Estima tempo para terminar o processamento
//            |                   |
// -----------+-------------------+-----------------------------------------------------------

Static Function EstTime(nTotal,nAtual,nIni,nTimeIni,nTimeZero)

Local cRet := ""
Local nTimeAtu := Seconds()
Local nHora , nMinutos, nSegundos

If (nAtual-nIni)>0
	nSegundos := (nTotal-nAtual)*(nTimeAtu-nTimeIni)/(nAtual-nIni)
Else
	nSegundos := 0
EndIf

nHora := Int(nSegundos/(60*60))
nSegundos := Mod(nSegundos,(60*60))
nMinutos := Int(nSegundos/(60))
nSegundos := Mod(nSegundos,(60))

If nTotal>0
	cRet := Str(nAtual/nTotal*100,3) + " % - "
Else
	cRet := Str(100,3) + " % - "
EndIf
	

cRet += ""+If(nHora>0,Str(nHora,3,0)+" horas, ","")+If(nMinutos>0,Str(nMinutos,3,0)+" minutos e ","")+If(nSegundos>0,Str(nSegundos,3,0)+" segundos ","")

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบ Programa  ณ CRIALOG                                บ Data ณ 08/07/2015 บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบ Autor     ณ Microsiga                                                  บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Descricao ณ Rotina para criar o arquivo de log de erros.               บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe   ณ CRIALOG(aLog, cArq)                                        บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno   ณ nil                                                        บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso       ณ Rede Dor Sใo Luiz                                          บฑฑ
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function CRIALOG(aLog, cArquivo, nQbrLin)

Local cFile := cArquivo + "_" + StrZero(Day(Date()),2,0) + "_" + StrZero(Month(Date()),2,0) + "_" + ALLTRIM(Str(Year(Date()))) + ".LOG"
Local nH
Local nCont := 1
Local X:=1

nH := fCreate(cFile)

If nH == -1
   MsgStop("Falha ao criar arquivo - erro "+str(ferror()))
   Return
Endif

fWrite(nH,"DATA DA IMPORTACAO : " + StrZero(Day(Date()),2,0) + "/" + StrZero(Month(Date()),2,0) + "/" + ALLTRIM(Str(Year(Date()))) + chr(13) + chr(10))
fWrite(nH,REPLICATE("-",60) + chr(13) + chr(10))

For X:=1 To LEN(aLog)
	fWrite(nH,PADR(aLog[X][1],8) + " : " + aLog[X][2]+chr(13)+chr(10) )
	If nCont = nQbrLin
		fWrite(nH,"------------------------------------------------------------" + chr(13) + chr(10) )
		nCont := 0
	EndIf
	nCont++
Next X

fClose(nH)

Return