#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#include "fivewin.ch"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa  � IMPORTPRO                              � Data � 06/11/2019 ���
��������������������������������������������������������������������������͹��
��� Autor     � Marcelo - Ethosx                                           ���
��������������������������������������������������������������������������͹��
��� Descricao � Rotina para a importa��o dos Produtos do template CSV para ���
���           � o ERP Protheus.                                            ���
��������������������������������������������������������������������������͹��
��� Sintaxe   � IMPORTPRO()                                                ���
��������������������������������������������������������������������������͹��
��� Retorno   � nil                                                        ���
��������������������������������������������������������������������������͹��
��� Uso       � 3Corp                                                      ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

User Function IMPORTPRO()

Local aArea		:= GetArea()
Local lConv     := .F.

Private cArquivo := Space(150)
Private lOk      :=.F.
Private bOk      := { || If(ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
Private bCancel  := { || lOk:=.F.,oDlg:End() }
Private lEnd     := .F.
Private aLog    := {}

Define MsDialog oDlg Title "Importa��o de Produtos" From 08,15 To 25,120 Of GetWndDefault()
      
@ 45,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
@ 45,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
@ 45,275 Button "�" 			Size 010,10 Action Eval({|| cArquivo:=SelectFile() }) Of oDlg Pixel

Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

If lOk
	oProcess:=MsNewProcess():New( { |lEnd| lConv:=u_ImpProCSV(cArquivo, @lEnd)}, "Importa��o de Produtos", "Processando arquivo de Produtos", .F. )
	oProcess:Activate()
	If lConv
		// cria arquivo de LOG
		CRIALOG(aLog, SUBSTR(cArquivo,1,LEN(cArquivo)-4), 3)
	EndIf
EndIf

RestArea(aArea)

Return 

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa  � IMPPROCSV                              � Data � 06/11/2019 ���
��������������������������������������������������������������������������͹��
��� Autor     � Marcelo - Ethosx                                           ���
��������������������������������������������������������������������������͹��
��� Descricao � Rotina para a importa��o dos Produtos to template CSV para ���
���           � o ERP Protheus.                                            ���
��������������������������������������������������������������������������͹��
��� Sintaxe   � IMPPROCSV(cArq, lEnd)                                      ���
��������������������������������������������������������������������������͹��
��� Retorno   � nil                                                        ���
��������������������������������������������������������������������������͹��
��� Uso       � 3Corp                                                      ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

User Function ImpProCSV(cArquivo, lEnd)

Local aVetor   := {}
Local aDados   := {}
Local aArea		:= GetArea()
Local cLinha
Local nTot     := 0
Local nCont    := 1
Local nAtual   := 0
Local nTimeIni := 0
Local nLinTit  := 1  // Total de linhas do Cabe�alho
Local aCampos 	:= {} 
Local nPosCod	:= 0
Local nPosDes	:= 0

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

// Tratamento do cabe�alho
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
		MsgInfo("Importa��o cancelada!","Fim")
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
	
	aDados := SEPARA(cLinha,";",.T.)

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

		If !Empty(aDados[X])
		
			AADD(aVetor,{aCampos[X],aDados[X] ,Nil}) // Codigo
		
		EndIf

	Next X
	
	MSExecAuto({|x,y| Mata010(x,y)},aVetor,3) //3- Inclus�o, 4- Altera��o, 5- Exclus�o
			
	If lMsErroAuto
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
		
		nPosCod  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "B1_COD" })
		nPosDes  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "B1_DESC" })
		
		If nPosCod <> 0
			AADD(aLog,{"B1_COD" 	,aDados[nPosCod] ,Nil}) // Codigo
		EndIf
		AADD(aLog,{"B1_DESC" 	,aDados[nPosDes] ,Nil}) // Descri��o
		AADD(aLog,{"ERRO" 		,cDescErro + " - " + cCampo ,Nil}) // Descri��o
		
		lMsErroAuto := .F.
		
	Endif
	
	FT_FSKIP()
	nCont++
	
EndDo

FT_FUSE()

Aviso("Finalizado","Importacao Finalizada - " + IIF(Empty(aLog),"Com Sucesso!!!	", "Verifique Arquivo de Log"),{"Fechar"})

RestArea(aArea)

Return .T.

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa  � SELECTFILE                             � Data � 10/07/2015 ���
��������������������������������������������������������������������������͹��
��� Autor     � Microsiga                                                  ���
��������������������������������������������������������������������������͹��
��� Descricao � Rotina para selecao de arquivos CSV para importacao        ���
���           �                                                            ���
��������������������������������������������������������������������������͹��
��� Sintaxe   � SELECTFILE()                                               ���
��������������������������������������������������������������������������͹��
��� Retorno   � cArquivo                                                   ���
��������������������������������������������������������������������������͹��
��� Uso       � Rede Dor S�o Luiz                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function SelectFile()

Local cMaskDir := "Arquivos .CSV (*.CSV) |*.CSV|"
Local cTitTela := "Arquivo para a integracao"
Local lInfoOpen := .T.
Local lDirServidor := .F.
Local cOldFile := cArquivo

cArquivo := cGetFile(cMaskDir,cTitTela,,cArquivo,lInfoOpen, (GETF_LOCALHARD+GETF_NETWORKDRIVE) ,lDirServidor)

If !File(cArquivo)
	MsgStop("Arquivo N�o Existe!")
	cArquivo := cOldFile
Return .F.
EndIf

Return cArquivo

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa  � VALIDADIR                              � Data � 10/07/2015 ���
��������������������������������������������������������������������������͹��
��� Autor     � Microsiga                                                  ���
��������������������������������������������������������������������������͹��
��� Descricao � Rotina para validacao do diretorio do arquivos CSV a ser   ���
���           � importado.                                                 ���
��������������������������������������������������������������������������͹��
��� Sintaxe   � VALIDADIR(cArquivo)                                        ���
��������������������������������������������������������������������������͹��
��� Retorno   � Logico                                                     ���
��������������������������������������������������������������������������͹��
��� Uso       � Rede Dor S�o Luiz                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ValidaDir(cArquivo)
Local lRet := .T.

If Empty(cArquivo)
	MsgStop("Selecione um arquivo","Aten��o")
	lRet := .F.
ElseIf !File(cArquivo)
	MsgStop("Selecione um arquivo v�lido!","Aten��o")
	lRet := .F.
EndIf

Return lRet


// ###########################################################################################
// Projeto:
// Modulo :
// Fun��o : 
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa  � CRIALOG                                � Data � 08/07/2015 ���
��������������������������������������������������������������������������͹��
��� Autor     � Microsiga                                                  ���
��������������������������������������������������������������������������͹��
��� Descricao � Rotina para criar o arquivo de log de erros.               ���
���           �                                                            ���
��������������������������������������������������������������������������͹��
��� Sintaxe   � CRIALOG(aLog, cArq)                                        ���
��������������������������������������������������������������������������͹��
��� Retorno   � nil                                                        ���
��������������������������������������������������������������������������͹��
��� Uso       � Rede Dor S�o Luiz                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static function CRIALOG(aLog, cArquivo, nQbrLin)

Local cFile := cArquivo + "_" + StrZero(Day(Date()),2,0) + "_" + StrZero(Month(Date()),2,0) + "_" + ALLTRIM(Str(Year(Date()))) + ".LOG"
Local nH
Local nCont := 1  
Local x:= 1

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