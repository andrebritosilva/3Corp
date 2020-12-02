	#INCLUDE "Protheus.ch"
#include "rwmake.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

User Function F580ADDB()

Local aRet := aClone(ParamIxb[1])

	aadd(aRet,{"Solicitar Aprova.","U_LibTit()",0,2,0,NIL})

Return aRet

User Function LibTit()


Local oProcess       := Nil                                            //Objeto da classe TWFProcess.
Local cMailId        := ""                                            //ID do processo gerado.
Local cHostWF        := GetMV("MV_XURL")//"3corptechnology107918.protheus.cloudtotvs.com.br:8800"//"http://localhost:8090" 
Local cTo            := GetMV("MV_XEMAIL")//"andrebritosilva@gmail.com"        //Destinatário de email.     
Local lCont          := GetMV("MV_XCONTWF")
Local cQuery         := ""
Local cAliasTop      := GetNextAlias() 
Local cLink          := ""
Local lAnexo         := .F.
Local cDrive, cDir, cNome, cExt

If !lCont
	MsgInfo("Processo desabilitado, verifique com Administrador!","Desabilitado")
	Return
EndIf

If SE2->E2_STATLIB == "03"
	MsgInfo("Título já liberado!","Liberado")
	Return
EndIf

cTo := Alltrim(cTo)

If MSGYESNO( "Deseja anexar um arquivo?", "Anexo" )
     
     lAnexo := .T.
    //Chamando o cGetFile para pegar um arquivo txt ou xml, mostrando o servidor
    cArqAux := cGetFile( ,; //[ cMascara], 
                         'Selecao de Arquivos',;                  //[ cTitulo], 
                         0,;                                      //[ nMascpadrao], 
                         'C:\',;                            //[ cDirinicial], 
                         .F.,;                                    //[ lSalvar], 
                         GETF_LOCALHARD  + GETF_NETWORKDRIVE,;    //[ nOpcoes], 
                         .T.)                                     //[ lArvore] 
    
    
    SplitPath( cArqAux, @cDrive, @cDir, @cNome, @cExt )
    
    cLinkAnexo := "http://" + cHostWF + "/workflow/arquivos/" + cNome + cExt
    
	If CpyT2S( cArqAux, "\workflow\arquivos" )
	 Conout( 'Copiado com Sucesso' )
	Endif
Else
	cArqAux := ""
EndIf

//-------------------------------------------------------------------

// "FORMULARIO"

//-------------------------------------------------------------------        

// Instanciamos a classe TWFProcess informando o código e nome do processo.

oProcess := TWFProcess():New("000001", "Financeiro")

// Criamos a tafefa principal que será respondida pelo usuário.

oProcess:NewTask("Financeiro", "\workflow\wfpcfin.htm")

// Atribuímos valor a um dos campos do formulário.
oProcess:oHtml:ValByName("cTitulo"      , SE2->E2_NUM)
oProcess:oHtml:ValByName("cNomeEmp"     , SE2->E2_FILIAL)
oProcess:oHtml:ValByName("cCodUser"     , __CUSERID)
oProcess:oHtml:ValByName("cNomeUser"    , UsrRetName (__CUSERID) )
oProcess:oHtml:ValByName("Prefixo"      , SE2->E2_PREFIXO)
oProcess:oHtml:ValByName("NumTit"       , SE2->E2_NUM)
oProcess:oHtml:ValByName("Parcela"      , SE2->E2_PARCELA )
oProcess:oHtml:ValByName("Tipo"         , SE2->E2_TIPO)
oProcess:oHtml:ValByName("nat"          , U_BuscaNat(SE2->E2_NATUREZ) )
oProcess:oHtml:ValByName("Fornecedor"   , SE2->E2_FORNECE + " " + U_BuscaFor(SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_FILIAL) )
oProcess:oHtml:ValByName("Loja"         , SE2->E2_LOJA    )
oProcess:oHtml:ValByName("Valor"        , SE2->E2_VALOR   )
oProcess:oHtml:ValByName("Vencimento"   , SE2->E2_VENCTO  )
oProcess:oHtml:ValByName("Saldo"        , SE2->E2_SALDO   )
oProcess:oHtml:ValByName("Custo"        , U_BuscaCC(SE2->E2_CCUSTO)     )
oProcess:oHtml:ValByName("Historico"    , SE2->E2_HIST    )
If lAnexo
	oProcess:oHtml:ValByName("arquivos"    , "arquivos/" + cNome + cExt )
EndIf


// Informamos qual função será executada no evento de timeout.

//oProcess:bTimeOut        := {{"u_wfTimeout()", 0, 0, 5 }}

// Informamos qual função será executada no evento de retorno.  

oProcess:bReturn        := "U_wfRetFin"

// Iniciamos a tarefa e recuperamos o nome do arquivo gerado.  

cMailID := oProcess:Start("\workflow")    

//-------------------------------------------------------------------

// "LINK"

//-------------------------------------------------------------------

 

// Criamos o ling para o arquivo que foi gerado na tarefa anterior.

oProcess:NewTask("LINK", "\workflow\link.htm")

// Atribuímos valor a um dos campos do formulário.

cLink := "http://" + cHostWF + "/workflow/" + cMailId + ".htm" 

oProcess:oHtml:ValByName("cLinkExt" , cLink)
oProcess:oHtml:ValByName("cLinkInt" , cLink)       

// Informamos o destinatário do email contendo o link.

oProcess:cTo                := cTo          

// Informamos o assunto do email.

oProcess:cSubject        := "Workflow Aprovação de Baixa de Título"

// Iniciamos a tarefa e enviamos o email ao destinatário.

oProcess:Start()  
oProcess:Finish()

MsgInfo("Solicitação enviada com sucesso!","Solicitação")

Return

User Function wfRetFin(oRet)

Local cQuery    := ""
Local cFilTit   := AllTrim(oRet:oHtml:RetByName("cNomeEmp"))
Local cPrefixo  := AllTrim(oRet:oHtml:RetByName("Prefixo"))  
Local cTit      := AllTrim(oRet:oHtml:RetByName("NumTit"))  
Local cParcela  := AllTrim(oRet:oHtml:RetByName("Parcela"))
Local cTipo     := AllTrim(oRet:oHtml:RetByName("Tipo"))
Local cAprova   := AllTrim(oRet:oHtml:RetByName("APROVA")) //Obtem resposta
Local cObs      := AllTrim(oRet:oHtml:RetByName("OBS")) 
Local cNome     := AllTrim(oRet:oHtml:RetByName("cNomeUser"))
Local cFornece  := AllTrim(oRet:oHtml:RetByName("Fornecedor"))
Local cLoja     := AllTrim(oRet:oHtml:RetByName("Loja"))
Local cValor    := oRet:oHtml:RetByName("Valor")
Local cCodUser  := AllTrim(oRet:oHtml:RetByName("cCodUser"))    
Local lRet      := .T.
Local cCodFor   := ""
Local aArea     := GetArea()
Local oProcess  := Nil         
Local oHtml	    := NIL			
Local oP		:= NIL
Local cTo       := ""
Local cMensagem := ""
Local cPara     := UsrRetMail(cCodUser)
Local cEmail    := ""

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "02"

//cFilTit   := Padr(cFilTit,TamSx3('E2_FILIAL')[1])
cPrefixo  := Padr(cPrefixo,TamSx3('E2_PREFIXO')[1])  
cTit      := Padr(cTit,TamSx3('E2_NUM')[1])  
cParcela  := Padr(cParcela,TamSx3('E2_PARCELA')[1])
cTipo     := Padr(cTipo,TamSx3('E2_TIPO')[1])
cCodFor   := SUBSTR(cFornece, 1, 6) 

If cAprova = "1"
	DbSelectArea("SE2")
	DbSetOrder(1)
	If DbSeek(cFilTit + cPrefixo + cTit + cParcela + cTipo + cCodFor + cLoja)
	
		If !Empty(SE2->E2_DATASUS) .Or. !Empty(SE2->E2_DATACAN)
			lRet := .F.	
		EndIf   
		
		If lRet
			//Begin Transaction
			
				RecLock("SE2",.F.)
					SE2->E2_DATALIB := dDataBase
					SE2->E2_USUALIB := cNome
					SE2->E2_STATLIB := "03"
					SE2->E2_APROVA  := UsrRetName ('000016')
					SE2->E2_CODAPRO := Fa006User( '000016', .F., 2 )
				MsUnlock()
				
				oP := TWFProcess():New("000002", "Treinamento")

				If cAprova == "1"
					oP:NewTask("FORMULARIO", "\workflow\finap.html")
				Else
					oP:NewTask("FORMULARIO", "\workflow\finrp.html")
				EndIf
				
				oP:oHtml:ValByName("cUsuario", cNome )
				oP:oHtml:ValByName("titulo"  , cTit  )
				oP:oHtml:ValByName("valor"   , cValor  )
				oP:oHtml:ValByName("motivo"  , cObs  )
				
				cEmail := UsrRetMail(cCodUser)
				oP:cTo := Alltrim(cEmail)
				
				If cAprova == "1"
					oP:cSubject        := "Baixa do titulo " + cTit + " aprovada"
				Else
					oP:cSubject        := "Baixa do titulo " + cTit + " reprovada"
				EndIf
				
				//cMailID := oP:Start()    
				
				//oP:cTo                := cTo          
				
				oP:cSubject        := "Workflow Liberação de Título"
				
				oP:Start()   
				oP:Finish()
				
			//End Transaction               
		EndIf
	EndIf
Else

	oP := TWFProcess():New("000002", "Treinamento")

	If cAprova == "1"
		oP:NewTask("FORMULARIO", "\workflow\finap.html")
	Else
		oP:NewTask("FORMULARIO", "\workflow\finrp.html")
	EndIf
	
	oP:oHtml:ValByName("cUsuario", cNome )
	oP:oHtml:ValByName("titulo"  , cTit  )
	oP:oHtml:ValByName("valor"   , cValor  )
	oP:oHtml:ValByName("motivo"  , cObs  )
	
	cEmail := UsrRetMail(cCodUser)
	oP:cTo := Alltrim(cEmail)
	
	If cAprova == "1"
		oP:cSubject        := "Baixa do titulo " + cTit + " aprovada"
	Else
		oP:cSubject        := "Baixa do titulo " + cTit + " reprovada"
	EndIf
	     
	
	oP:cSubject        := "Workflow Liberação de Título"
	
	oP:Start()   
	oP:Finish()
	
EndIf

RestArea(aArea)

Return

User Function BuscaFor(cCod,cLoja, cFilTit)

Local cQuery    := ""
Local aArea     := GetArea()
Local cDesc     := ""

cFilTit      := Padr(cFilTit,TamSx3('E2_FILIAL')[1])
cCod         := Padr(cCod,TamSx3('E2_FORNECE')[1])
cLoja        := Padr(cLoja,TamSx3('E2_LOJA')[1])    

DbSelectArea("SA2")
DbSetOrder(1)
If SA2->(DbSeek(xFilial("SA2") + cCod + cLoja))
	cDesc := Alltrim(SA2->A2_NOME)
Else
	cDesc := "Forne. não encontrado"
EndIf

RestArea(aArea)

Return cDesc

User Function BuscaNat(cCod)

Local aArea     := GetArea()
Local cDesc     := ""

cCod         := Padr(cCod,TamSx3('ED_CODIGO')[1])    

DbSelectArea("SED")
DbSetOrder(1)
If SED->(DbSeek(xFilial("SED") + cCod))
	cDesc := Alltrim(SED->ED_DESCRIC)
Else
	cDesc := "Natureza não encontrada"
EndIf

RestArea(aArea)

Return cDesc

User Function BuscaCC(cCod)

Local aArea     := GetArea()
Local cDesc     := ""

cCod         := Padr(cCod,TamSx3('CTT_CUSTO')[1])    

DbSelectArea("CTT")
DbSetOrder(1)
If CTT->(DbSeek(xFilial("CTT") + cCod))
	cDesc := Alltrim(CTT->CTT_CUSTO)
Else
	cDesc := "Centro de Custo não encontrado"
EndIf

RestArea(aArea)

Return cDesc