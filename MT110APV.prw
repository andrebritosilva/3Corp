#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//SAK
User Function MT110APV() 

Local aArea   := GetArea()
Local lRet    := .F.

DbSelectArea("SAK")
DbGoTop()

While !SAK->(Eof())

If __cUserID == SAK->AK_USER

	lRet := .T.
	Exit

EndIf

SAK->(dbSkip())

EndDo

If !lRet
	MsgInfo("Rotina n�o liberada para este usu�rio, solicite ao administrador!","Desabilitado")
EndIf
  
RestArea( aArea )

Return lRet