#Include "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description

@param xParam Parameter Description
@return xRet Return Description
@author Fiorato - Ethosx
@since 18/05/2020
/*/
//--------------------------------------------------------------
User Function MySql()
Local oButton1
Local oFont1 := TFont():New("News706 BT",,020,,.T.,,,,,.F.,.F.)
Local oGet1
Local cGet1 := "Tabela..."
Local oMultiGe1
Local cMultiGe1 := "Digite o comando..."
Local oSay1
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL
    @ 008, 176 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 024, 011 GET oMultiGe1 VAR cMultiGe1 OF oDlg MULTILINE SIZE 228, 197 COLORS 0, 16777215 HSCROLL PIXEL
    @ 005, 077 SAY oSay1 PROMPT "Comandos SQL" SIZE 098, 017 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 227, 111 BUTTON oButton1 PROMPT "Executar" SIZE 037, 012 OF oDlg ACTION Exec(cGet1,cMultiGe1) PIXEL
   
  ACTIVATE MSDIALOG oDlg CENTERED

Return

STATIC function exec(cGet1,cMultiGe1)

DbSelectArea(cGet1)
   
cStrSql := cMultiGe1
    
lResult := TCSQLEXEC(cStrSql)
If lResult < 0
   Return 
   MsgStop("Erro durante a Update: " + TCSQLError())
   conout("TCSQLError() " + TCSQLError())
EndIf 
	
ALERT("UPDATE REALIZADO")
return