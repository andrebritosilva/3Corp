#INCLUDE "Protheus.ch"
#include "rwmake.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

/*/{Protheus.doc} MTA094RO
Opção de envio de WF de Pedido de Compras
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function MTA094RO()

Private aRotina:= PARAMIXB[1]

Aadd(aRotina,{'Workflow',"U_LibPed()", 0, 4,0,NIL})

//Validações do usuário

Return (aRotina)

/*/{Protheus.doc} LibPed
Montagem de WF 
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function LibPed()

Local oProcess       := Nil                                            //Objeto da classe TWFProcess.
Local cMailId        := ""                                            //ID do processo gerado.
Local cHostWF        := GetMV("MV_XURL")  //"3corptechnology107918.protheus.cloudtotvs.com.br:8800"
Local cTo            := GetMV("MV_XMAILPE")   
Local lCont          := GetMV("MV_XCONWFP")
Local cPedido        := Alltrim(SCR->CR_NUM)//SC7->C7_NUM
Local cFilPed        := Alltrim(SCR->CR_FILIAL)//SC7->C7_NUM
Local cQuery         := ""
Local cAliasTop      := GetNextAlias()
Local cAliasTop1     := GetNextAlias()  
Local cLinkAnexo     := ""
Local cLink          := ""
Local cArqAux        := ""
Local cFornecedor    := ""
Local nTotPed        := 0
Local nTotFre        := 0
Local nTotDesp       := 0
Local cProduto       := ""
Local lAnexo         := .F.
Local cLinkAx        := ""
Local aLinks         := {}
Local nTotMerc       := 0
Local nTotDesc       := 0
Local cTes           := ""
Local lRetTes        := .F.
Local cCamArq        := "http://3corptechnology107917.protheus.cloudtotvs.com.br:8800/dirdoc/co01/shared/" //Caminho Prod
Local cDrive, cDir, cNome, cExt

//Quando nao confirmar o pedido retorna
/*If nOpc == 0
	Return
EndIf*/

If !lCont
	MsgInfo("Processo desabilitado, verifique com Administrador!","Desabilitado")
	Return
EndIf

cTo := Alltrim(cTo)

If MSGYESNO( "Deseja enviar workflow de aprovação?", "Aprovação" )
	
	/*If MSGYESNO( "Deseja anexar um arquivo?", "Anexo" )
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
	Else*/
		cArqAux := ""
	//EndIf
	
	cQuery := "SELECT ISNULL(CAST(CAST(C7_XOBSM AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS OBS,* FROM "
	cQuery += RetSqlName("SC7") + " SC7 "
	cQuery += "WHERE C7_FILIAL = '" + cFilPed + "' AND C7_NUM = '" + cPedido + "' AND D_E_L_E_T_ = ' ' "
		
	cQuery := ChangeQuery(cQuery) 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	
	cTo := U_BscAprovador((cAliasTop)->C7_FILIAL, (cAliasTop)->C7_NUM)
	
	aLinks := U_BusAnexo((cAliasTop)->C7_FILIAL,(cAliasTop)->C7_NUM)
	
	cTes   := (cAliasTop)->C7_TES
	
	If (cTes == "001" .Or. cTes == "002" .Or. cTes == "399" .Or. cTes == "400")
	
		lRetTes := U_RetTes((cAliasTop)->C7_FILIAL,(cAliasTop)->C7_NUM)
		
		If lRetTes
			MsgInfo("TES " + cTes + " utilizada não precisa de aprovação superior!","Solicitação")
			Return
		EndIf	
		
	EndIf
	
	oProcess := TWFProcess():New("000001", "Pedido")
	
	// Criamos a tafefa principal que será respondida pelo usuário.
	
	oProcess:NewTask("FORMULARIO", "\Workflow\wfpc.htm")
	
	// Atribuímos valor a um dos campos do formulário.
	
	oProcess:oHtml:ValByName("cPedido"    , (cAliasTop)->C7_NUM )
	oProcess:oHtml:ValByName("cNomeEmp"   , (cAliasTop)->C7_FILIAL )
	oProcess:oHtml:ValByName("dEmissao"   , STOD((cAliasTop)->C7_EMISSAO) )
	oProcess:oHtml:ValByName("dTPagto"    , dDataBase )
	oProcess:oHtml:ValByName("cFornece"   , U_BusFor((cAliasTop)->C7_FORNECE,(cAliasTop)->C7_LOJA) )
	oProcess:oHtml:ValByName("cComprador" , Alltrim((cAliasTop)->C7_USER) + " " + Alltrim(UsrFullName((cAliasTop)->C7_USER)) )
	oProcess:oHtml:ValByName("cAprovador" , U_ProcAprov((cAliasTop)->C7_FILIAL, (cAliasTop)->C7_NUM))
	oProcess:oHtml:ValByName("nIpi"       , TRANSFORM((cAliasTop)->C7_IPI,'@E 999,999.99'))
	oProcess:oHtml:ValByName("cSolic"     , U_CodSol((cAliasTop)->C7_NUMSC) + " " + U_NomeSol((cAliasTop)->C7_NUMSC) )
	//oProcess:oHtml:ValByName("nValMerc"   , TRANSFORM((cAliasTop)->C7_TOTAL,'@E 999,999,999.99'))
	oProcess:oHtml:ValByName("cPag"       , U_CondPag((cAliasTop)->C7_COND ))//Buscar descrição da tabela
	//oProcess:oHtml:ValByName("nFrete"     , TRANSFORM((cAliasTop)->C7_VALFRE,'@E 999,999,999.99'))
	//oProcess:oHtml:ValByName("nDesc"      , Alltrim((cAliasTop)->C7_DESCRI ))
	//oProcess:oHtml:ValByName("nTotalr"    , TRANSFORM((cAliasTop)->C7_TOTAL, '@E 999,999,999.99'))//Verificar total real
	oProcess:oHtml:ValByName("nSt"        , TRANSFORM((cAliasTop)->C7_ICMSRET,'@E 999,999.99'))//Verificar com as meninas
	oProcess:oHtml:ValByName("IcmsRet"    , TRANSFORM((cAliasTop)->C7_ICMSRET,'@E 999,999.99'))//Verificar com as meninas
	oProcess:oHtml:ValByName("OBSPED"     ,Alltrim((cAliasTop)->C7_OBS) /*U_ObsSol((cAliasTop)->C7_FILIAL,(cAliasTop)->C7_NUMSC, Alltrim((cAliasTop)->C7_OBS ))*/ )
	oProcess:oHtml:ValByName("OBSPED2"    , Alltrim((cAliasTop)->OBS ))
	//If lAnexo 
		//oProcess:oHtml:ValByName("arquivos"   , "arquivos/" + cNome + cExt )
		//oProcess:oHtml:ValByName("arquivos"   , cCamArq + cLinkAx )
	//EndIf
	
	oProcess:oHtml:ValByName("arq" ,{})
	oProcess:oHtml:ValByName("T5.ANEXOS" ,{})
	
	If Len(aLinks) > 0

		For nX := 1 to Len(aLinks)
			cArquivo := cCamArq + aLinks[nX]

			aadd(oProcess:oHtml:ValByName("t5.arquivos"),cArquivo )
			aadd(oProcess:oHtml:ValByName("T5.ANEXOS" ),"Anexo "+StrZero(nX,2) )
		Next

	Else
  
		aadd(oProcess:oHtml:ValByName("t5.arquivos") ,"" )
		aadd(oProcess:oHtml:ValByName("T5.ANEXOS" ),"Sem Anexo " )
  
	EndIf
	
	cFornecedor := (cAliasTop)->C7_FORNECE
	cProduto    := (cAliasTop)->C7_PRODUTO
	
	While !(cAliasTop)->(EOF())
	
		nTotPed  += ((cAliasTop)->C7_TOTAL + (cAliasTop)->C7_VALFRE + (cAliasTop)->C7_DESPESA + (cAliasTop)->C7_VALIPI)
		nTotFre  += (cAliasTop)->C7_VALFRE
		nTotDesp += (cAliasTop)->C7_DESPESA
		nTotMerc += (cAliasTop)->C7_TOTAL
		nTotDesc += (cAliasTop)->C7_VLDESC
		
		
		aadd(oProcess:oHtml:ValByName("t1.cCod"    ), (cALIASTOP)->C7_PRODUTO)
		aadd(oProcess:oHtml:ValByName("t1.cDescri" ), (cALIASTOP)->C7_DESCRI)
		aadd(oProcess:oHtml:ValByName("t1.cUm"     ), (cALIASTOP)->C7_UM)
		aadd(oProcess:oHtml:ValByName("t1.nQuant"  ), TRANSFORM((cALIASTOP)->C7_QUANT,'@E 999,999.9999'))
		aadd(oProcess:oHtml:ValByName("t1.cCusto"  ), (cALIASTOP)->C7_CC)
		aadd(oProcess:oHtml:ValByName("t1.nIPI"    ), TRANSFORM((cALIASTOP)->C7_VALIPI,'@E 999,999.99'))
		aadd(oProcess:oHtml:ValByName("t1.nSt"     ), TRANSFORM((cAliasTop)->C7_ICMSRET,'@E 999,999.99'))
		aadd(oProcess:oHtml:ValByName("t1.nUnitr"  ), TRANSFORM((cALIASTOP)->C7_PRECO*(cALIASTOP)->C7_TXMOEDA,'@E 999,999.9999'))
		aadd(oProcess:oHtml:ValByName("t1.nTotal"  ), TRANSFORM((cALIASTOP)->C7_TOTAL,'@E 999,999,999.99'))	
				
		(cAliasTop)->(DBSkip())
	EndDo
	
	oProcess:oHtml:ValByName("nFrete"     , TRANSFORM(nTotFre,'@E 999,999,999.99'))
	oProcess:oHtml:ValByName("nDesp"      , TRANSFORM(nTotDesp,'@E 999,999,999.99'))
	oProcess:oHtml:ValByName("nValMerc"   , TRANSFORM(nTotMerc,'@E 999,999,999.99'))
	oProcess:oHtml:ValByName("nDesc"      , TRANSFORM(nTotDesc,'@E 999,999,999.99'))
	oProcess:oHtml:ValByName("nTotalr"    , TRANSFORM(nTotPed - nTotDesc, '@E 999,999,999.99'))//Verificar total real
	
	DbCloseArea(cAliasTop)
	
	cQuery := "SELECT TOP 3 * FROM "
	cQuery += RetSqlName("SC7") + " SC7 "
	cQuery += "WHERE C7_PRODUTO = '" + cProduto + "' AND D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY C7_EMISSAO DESC"
		
	cQuery := ChangeQuery(cQuery) 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop1,.T.,.T.)
	
	While !(cAliasTop1)->(EOF())
	
		aadd(oProcess:oHtml:ValByName("t2.cCod"    )  , (cAliasTop1)->C7_PRODUTO)
		aadd(oProcess:oHtml:ValByName("t2.cPedido" )  , (cAliasTop1)->C7_NUM)
		aadd(oProcess:oHtml:ValByName("t2.Fornece" )  , (cAliasTop1)->C7_FORNECE)
		aadd(oProcess:oHtml:ValByName("t2.nQuant"  )  , TRANSFORM((cAliasTop1)->C7_QUANT,'@E 999,999.9999'))
		aadd(oProcess:oHtml:ValByName("t2.nUnit"   )  , TRANSFORM((cAliasTop1)->C7_PRECO,'@E 999,999,999.99'))
		aadd(oProcess:oHtml:ValByName("t2.cCusto"  )  , (cAliasTop1)->C7_CC)
		aadd(oProcess:oHtml:ValByName("t2.nIPI"   )   , TRANSFORM((cAliasTop1)->C7_VALIPI,'@E 999,999,999.99'))
		aadd(oProcess:oHtml:ValByName("t2.nSt"     )  , TRANSFORM((cAliasTop1)->C7_ICMSRET,'@E 999,999,999.99'))
		aadd(oProcess:oHtml:ValByName("t2.dEmissao")  , STOD((cAliasTop1)->C7_EMISSAO) )
		aadd(oProcess:oHtml:ValByName("t2.cPgto"   )  , U_CondPag((cAliasTop1)->C7_COND) )	
				
		(cAliasTop1)->(DBSkip())
	EndDo
	
	DbCloseArea(cAliasTop1)
	
	oProcess:bReturn        := "u_wfRetPd()"
	
	// Iniciamos a tarefa e recuperamos o nome do arquivo gerado.  
	
	cMailID := oProcess:Start("\workflow")  
	
	//-------------------------------------------------------------------
	// "LINK"
	//-------------------------------------------------------------------
	
	oProcess:NewTask("LINK", "\workflow\link.htm")
	
	cLink := "http://" + cHostWF + "/workflow/" + cMailId + ".htm"
	
	oProcess:oHtml:ValByName("cLinkExt" , cLink)
	oProcess:oHtml:ValByName("cLinkInt" , cLink) 
	
	oProcess:cTo                := cTo          
	
	// Informamos o assunto do email.
	
	oProcess:cSubject        := "Workflow Pedido de Compras"
	
	// Iniciamos a tarefa e enviamos o email ao destinatário.
	
	oProcess:Start()  
	oProcess:Finish()
	
	MsgInfo("Solicitação enviada com sucesso!","Solicitação")
Else
	Return
EndIf  

/*/{Protheus.doc} wfRetPd
Trata retorno do WF, aprovando ou não o pedido de compra
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function wfRetPd(oRet)

Local cQuery           := ""
Local filpedido        := AllTrim(oRet:oHtml:RetByName("cNomeEmp"))  
Local numpedido        := AllTrim(oRet:oHtml:RetByName("cPedido")) 
Local cAprova          := AllTrim(oRet:oHtml:RetByName("APROVA"))
Local cSolic           := AllTrim(oRet:oHtml:RetByName("cComprador"))//AllTrim(oRet:oHtml:RetByName("cSolic"))
Local cValor           := oRet:oHtml:RetByName("nTotalr")
Local cObs             := AllTrim(oRet:oHtml:RetByName("OBS"))
Local oP		       := NIL
Local cTo              := ""
Local cMensagem        := ""
Local cEmail           := ""
Local cCodSolic        := ""
Local cAliAux          := GetNextAlias()
Local cGrupo           := ""
Local cMailCopy        := ""

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "02"

cCodSolic := SUBSTR(cSolic,1,6)
cEmail    := UsrRetMail(cCodSolic)
 
cQuery	:= " SELECT CR_STATUS, CR_USER, CR_APROV, CR_NIVEL FROM "+RetSqlName("SCR")+ " "
cQuery  += " WHERE CR_FILIAL = '"+alltrim(filpedido)+"' "
cQuery  += " AND CR_NUM = '"+alltrim(numpedido)+"' "
cQuery  += " AND CR_STATUS = '02'"
cQuery  += " AND D_E_L_E_T_ = '' "
cQuery	:=	ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)  

cCR_STATUS := (cAliAux)->CR_STATUS
cCR_USER   := (cAliAux)->CR_USER
cCR_APROV  := (cAliAux)->CR_APROV  

cMailCopy  := U_EmailCc(filpedido,numpedido)

DbSelectArea("SC7")
SC7->( DbSetOrder(1) )
If SC7->( DbSeek(xFilial("SC7")+ alltrim(numpedido)))
	cGrupo := SC7->C7_APROV
EndIf
	
If cAprova == "1"
	If cCR_STATUS == '02'
		DbSelectArea("SCR")
		SCR->(DbSetOrder(1)) //-- CR_FILIAL+CR_TIPO+CR_NUM+CR_APROV + CR_USER
		If SCR->(dbSeek(alltrim(filpedido) + "PC" + alltrim(numpedido)/* + cCR_USER*/ ))
			
			lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,/*SCR->CR_APROV*/,SCR->CR_USER,cGrupo,,,,,},dDataBase,4)
			
			If lLiberou
				U_LibScr(filpedido,numpedido)
			EndIf 
			
			If lLiberou
				dbSelectArea("SC7")
				SC7->(dbSetOrder(1)) 
				SC7->(dbSeek(alltrim(filpedido)+alltrim(numpedido)))
									    
				dbSelectArea("SC7")
				SC7->(dbSetOrder(1)) 
			    SC7->(dbSeek(alltrim(filpedido)+alltrim(numpedido)))
				While !Eof() .And. SC7->C7_FILIAL+SC7->C7_NUM == alltrim(filpedido)+alltrim(numpedido)
					Reclock("SC7",.F.)
					SC7->C7_CONAPRO := "L"
					ConOut( "Legenda alterada")
					MsUnlock()
					dbSkip()
				EndDo
				
				ConOut( "Pedido Liberado pelo usuario")
				
				cMensagem := "Pedido Liberado pelo usuario"
					
			Else
				ConOut( "Pedido não Liberado")
				cMensagem := "Pedido não Liberado"
			EndIf
			
		Else
			ConOut( "Pedido excluido pelo comprador")
			cMensagem := "Pedido excluido pelo comprador"
		EndIf
			
	Else
		If (cCR_STATUS=='01')  
		    cMensagem := "Bloqueado pelo sistema (aguardando outros niveis)"
		    ConOut("Bloqueado pelo sistema (aguardando outros niveis)")
		EndIf    
		If (cCR_STATUS=='02')  
		    cMensagem := "Aguardando Liberacao do usuario"
		    ConOut("Aguardando Liberacao do usuario")
		EndIf    
		If (cCR_STATUS=='03')   
		    cMensagem := "Pedido ja Liberado anteriormente pelo usuario"
		    ConOut("Pedido ja Liberado anteriormente pelo usuario")
		EndIf    
		If (cCR_STATUS=='05')  
			cMensagem := "Pedido Bloqueado por outro usuario"	
			ConOut("Pedido Bloqueado por outro usuario")		
		EndIf    
		If (cCR_STATUS=='04')  
		    cMensagem := "Pedido Bloqueado pelo usuario" 
		    ConOut("Pedido Bloqueado pelo usuario" )
		EndIf    
		If Empty(cCR_STATUS)
		    cMensagem := "Pedido Excluido pelo comprador"
		    ConOut("Pedido Excluido pelo comprador")
		EndIf    
	EndIf
	
EndIf

(cAliAux)->(DbCloseArea())

oP := TWFProcess():New("000002", "PedidoCompra")

If cAprova == "1"
	oP:NewTask("FORMULARIO", "\workflow\pcap.html")
Else
	oP:NewTask("FORMULARIO", "\workflow\pcrp.html")
EndIf

oP:oHtml:ValByName("cUsuario", Alltrim(cSolic) )
oP:oHtml:ValByName("pedido"  , numpedido  )
oP:oHtml:ValByName("valor"   , cValor  )
oP:oHtml:ValByName("motivo"  , cObs  )

cEmail := Alltrim(cEmail)
oP:cTo := cEmail
//oP:cCC := Alltrim(cMailCopy)

If cAprova == "1"
	oP:cSubject        := "Pedido de compra" + numpedido + " aprovado"
Else
	oP:cSubject        := "Pedido de compra" + numpedido + " reprovado"
EndIf

oP:cSubject        := "Workflow Pedido de Compras"

oP:Start()   

//U_GrvObs(filpedido,numpedido,cObs)

oP:Finish() 

Return

/*/{Protheus.doc} BusFor
Busca nome de Fornecedor
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function BusFor(cCod,cLoja)

Local cQuery    := ""
Local aArea     := GetArea()
Local cDesc     := ""

cCod         := Padr(cCod,TamSx3('C7_FORNECE')[1])
cLoja        := Padr(cLoja,TamSx3('C7_LOJA')[1])    

DbSelectArea("SA2")
DbSetOrder(1)
If SA2->(DbSeek(xFilial("SA2") + cCod + cLoja))
	cDesc := Alltrim(SA2->A2_NOME)
Else
	cDesc := "Forne. não encontrado"
EndIf

RestArea(aArea)

Return cDesc

/*/{Protheus.doc} CondPag
Busca Condição de Pagamento
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function CondPag(cCod)

Local aArea     := GetArea()
Local cDesc     := ""

cCod         := Padr(cCod,TamSx3('E4_CODIGO')[1])    

DbSelectArea("SE4")
DbSetOrder(1)
If SE4->(DbSeek(xFilial("SE4") + cCod))
	cDesc := Alltrim(SE4->E4_DESCRI)
Else
	cDesc := "Cond. Pag. não encontrado"
EndIf

RestArea(aArea)

Return cDesc

/*/{Protheus.doc} MTA094RO
Busca nome de aprovador
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function ProcAprov(cFilPed, cPedido)

Local aArea     := GetArea()
Local cNome     := ""
Local cCod      := ""

cPedido         := Padr(cPedido,TamSx3('CR_NUM')[1])    
cFilPed         := Padr(cFilPed,TamSx3('CR_FILIAL')[1])    

DbSelectArea("SCR")
DbSetOrder(1)
If SCR->(DbSeek(cFilPed + "PC" + cPedido))
	cCod := Alltrim(SCR->CR_APROV)
Else
	cCod  := ""
	cNome := "Aprovador não encontrado" 
	Return cNome
EndIf

DbSelectArea("SAK")
DbSetOrder(1)
If SAK->(DbSeek(xFilial("SAK") + cCod))
	cNome := Alltrim(SAK->AK_NOME)
Else
	cNome := "Aprovador não encontrado"
EndIf

RestArea(aArea)

Return cNome

/*/{Protheus.doc} MTA094RO
Busca próximo aprovador
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function BscAprovador(cFilPed, cPedido)

Local aArea     := GetArea()
Local cNome     := ""
Local cCod      := ""
Local cPed      := ""
Local cPedFil   := ""
Local cQuery    := ""
Local cAliAux   := GetNextAlias()//(cAliAux)->CT2_XOK

cPed    := Padr(cPedido,TamSx3('CR_NUM')[1])    
cPedFil := Padr(cFilPed,TamSx3('CR_FILIAL')[1])  

cQuery := "SELECT * FROM"
cQuery += RetSqlName("SCR") + " SCR "
cQuery += " WHERE CR_STATUS = '02'"
cQuery += " AND CR_FILIAL = '" + cFilPed +"'"
cQuery += " AND CR_NUM = '" + cPedido +"'"
cQuery += " AND D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)  

cCod  := Alltrim((cAliAux)->CR_USER)
cNome := Alltrim(UsrRetMail(cCod))

If Empty(cNome)
	cNome := GetMV("MV_XMAILPE")
EndIf

(cAliAux)->(DbCloseArea())

RestArea(aArea)

Return cNome

/*/{Protheus.doc} BusAnexo
Função de busca anexo no banco de conhecimento
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function BusAnexo(cFilCod,cNum)

Local cQuery    := ""
Local aArea     := GetArea()
Local cLink     := ""
Local aAttach   := {}

cFilCod    := Padr(cFilCod,TamSx3('C7_FILIAL')[1])
cNum       := Padr(cNum,TamSx3('C7_NUM')[1])    

DbSelectArea("AC9")
DbSetOrder(2)
If DbSeek(xFilial("AC9")+"SC7"+cFilCod+cFilCod+cNum )

While AC9->(!Eof()) .And. Substr(AC9->AC9_CODENT,1,8) ==  cFilCod+cNum
  
	DbSelectArea("ACB")
	DbSetOrder(1)
	DbSeek(xFilial("ACB")+AC9->AC9_CODOBJ )
		
	//cLink := Alltrim(ACB->ACB_OBJETO)
	aadd(aAttach,Alltrim(ACB->ACB_OBJETO))
	
	DbSelectArea("AC9")
	AC9->(DbSkip())
EndDo

EndIf

RestArea(aArea)

Return aAttach

/*/{Protheus.doc} NomeSol
Busca nome do solicitante
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function NomeSol(cNumSol)

Local aArea     := GetArea()
Local cSolic    := ""

DbSelectArea("SC1")
DbSetOrder(1)
If SC1->(DbSeek(xFilial("SC1")+ cNumSol ))
	cSolic := SC1->C1_SOLICIT
Else
	cSolic := UsrFullName(__cUserId) 
EndIf

RestArea(aArea)

Return cSolic

/*/{Protheus.doc} CodSol
Retorna o código do solicitante
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function CodSol(cNumSol)

Local aArea     := GetArea()
Local cSolic    := ""

DbSelectArea("SC1")
DbSetOrder(1)
If SC1->(DbSeek(xFilial("SC1")+ cNumSol ))
	cSolic := SC1->C1_USER
Else
	cSolic := __cUserId
EndIf

RestArea(aArea)

Return Alltrim(cSolic)

/*/{Protheus.doc} MTA094RO
Retorna o e-mail do usuário em cópia
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function EmailCc(filpedido,numpedido)

Local aArea     := GetArea()
Local cUsuario  := ""
Local cEmail    := ""

DbSelectArea("SC7")
SC7->( DbSetOrder(1) )
If SC7->(dbSeek(alltrim(filpedido)+alltrim(numpedido)))
	cUsuario := SC7->C7_USER
	cEmail   := UsrRetMail(cUsuario)
EndIf

RestArea(aArea)

Return cEmail

/*/{Protheus.doc} ObsSol
Retorna obsevação do pedido
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function ObsSol(cFilSol, cNumSol, cObserv)

Local aArea     := GetArea()
Local cObs      := ""

DbSelectArea("SC1")
DbSetOrder(1)
If SC1->(DbSeek(cFilSol + cNumSol ))
	cObs := SC1->C1_OBS
Else
	cObs := ""
EndIf

RestArea(aArea)

Return cObs

/*/{Protheus.doc} LibScr
Liberação de Alçada
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/


User Function LibScr(filpedido,numpedido)

Local aArea     := GetArea()
Local cQuery    := ""
Local cAliAux   := GetNextAlias()

cQuery	:= " SELECT R_E_C_N_O_ FROM "+RetSqlName("SCR")+ " "
cQuery  += " WHERE CR_FILIAL = '"+alltrim(filpedido)+"' "
cQuery  += " AND CR_NUM = '"+alltrim(numpedido)+"' "
cQuery  += " AND CR_STATUS = '02'"
cQuery  += " AND D_E_L_E_T_ = '' "
cQuery	:=	ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)  

SCR->(DbGoto((cAliAux)->R_E_C_N_O_))

RecLock("SCR",.F.)
	
	SCR->CR_DATALIB := dDataBase
	SCR->CR_USERLIB := SCR->CR_USER
	SCR->CR_LIBAPRO := SCR->CR_APROV
	SCR->CR_VALLIB  := SCR->CR_TOTAL
	SCR->CR_STATUS  := '03'
	
SCR->(MsUnLock())

(cAliAux)->(DbCloseArea())

RestArea(aArea)

Return

/*/{Protheus.doc} RetTes
Liberação do pedido de compras
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function RetTes(filpedido,numpedido)

Local aArea     := GetArea()
Local lLiberou  := .T.

DbSelectArea("SCR")
SCR->(DbSetOrder(1)) //-- CR_FILIAL+CR_TIPO+CR_NUM+CR_APROV + CR_USER
If SCR->(dbSeek(alltrim(filpedido) + "PC" + alltrim(numpedido)/* + cCR_USER*/ ))
	
	lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,/*SCR->CR_APROV*/,"000016",/*cGrupo*/,,,,,},dDataBase,4)
	
	If lLiberou
		U_LibScr(filpedido,numpedido)
		
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1)) 
		SC7->(dbSeek(alltrim(filpedido)+alltrim(numpedido)))
							    
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1)) 
	    SC7->(dbSeek(alltrim(filpedido)+alltrim(numpedido)))
		While !Eof() .And. SC7->C7_FILIAL+SC7->C7_NUM == alltrim(filpedido)+alltrim(numpedido)
			Reclock("SC7",.F.)
			SC7->C7_CONAPRO := "L"
			ConOut( "Legenda alterada")
			MsUnlock()
			dbSkip()
		EndDo
		
		ConOut( "Pedido Liberado pelo usuario")
		
		cMensagem := "Pedido Liberado pelo usuario"
			
		Else
			ConOut( "Pedido não Liberado")
			cMensagem := "Pedido não Liberado"
		EndIf
		
	EndIf


RestArea(aArea)

Return lLiberou

/*/{Protheus.doc} GrvObs
Grava observação do retorno do e-mail
@author Andre Brito
@since 12/07/2020
@version undefined
@type function
/*/

User Function GrvObs(filpedido,numpedido,cObs)

Local aArea     := GetArea()
Local cQuery    := ""
Local cAliAux   := GetNextAlias()

cQuery	:= " SELECT R_E_C_N_O_ FROM "+RetSqlName("SCR")+ " "
cQuery  += " WHERE CR_FILIAL = '"+alltrim(filpedido)+"' "
cQuery  += " AND CR_NUM = '"+alltrim(numpedido)+"' "
cQuery  += " AND CR_STATUS = '02'"
cQuery  += " AND D_E_L_E_T_ = '' "
cQuery	:=	ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)  

SCR->(DbGoto((cAliAux)->R_E_C_N_O_))

RecLock("SCR",.F.)
	
	SCR->CR_OBS := Alltrim(cObs)
	
SCR->(MsUnLock())

(cAliAux)->(DbCloseArea())

RestArea(aArea)

Return