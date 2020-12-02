#Include 'Protheus.ch'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} MTETHG01
Validação de usuário do campo B1_GRUPO para controle de numeração do B1_COD
@author Marcelo Franca - Ethosx
@since 07/11/2019
/*/

User Function MTETHG01()

	Local aArea			:= GetArea()
	Local cQuery 		:= ""
	Local lRet			:= .T.
	Local nNum			:= 0
	
		
	If INCLUI .And. Funname()<>"IMPORTPRO"
		
		cQuery += " SELECT COUNT(B1_COD) CONTADOR,MAX(B1_COD) B1_COD"
		cQuery += " FROM " + RETSQLNAME("SB1")
		cQuery += " WHERE B1_COD LIKE '"+M->B1_GRUPO + "%'"
		cQuery += " AND D_E_L_E_T_ = ''"
	
		cQuery := ChangeQuery(cQuery)
	
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "SB1TMP", .F., .T. )
    
		SB1TMP->(dbGoTop())

		If !SB1TMP->(CONTADOR) > 0
			//primeiro sequencial
			M->B1_COD		:=  SOMA1(M->B1_GRUPO + StrZero(0,4))
		Else
			//demais sequencial
			nNum		:= 	Val(SubStr(SB1TMP->(B1_COD),5,4))+1
			M->B1_COD	:=  M->B1_GRUPO + StrZero(nNum,4)
		Endif
	
		SB1TMP->(dbclosearea())
		
	Endif
	
	RestArea(aArea)	
	
Return lRet