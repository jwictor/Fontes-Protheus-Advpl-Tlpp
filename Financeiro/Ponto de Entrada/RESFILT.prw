#include 'totvs.ch'

User Function RESFILT

    LOCAL aGrupos       := StrTokArr(AllTrim(GetMV("SM_XGRRES")),";")
    LOCAL aUsrGrps      := UsrRetGrp()
    Local bCondicao     := {||E2_TIPO <> 'RES'}
   // Local lContinua     := .F.
    Local nX            := 0
    Local nY            := 0

    For nX := 1 To Len(aUsrGrps) // Para cada grupo do usu�rio
        For nY := 1 To Len(aGrupos) // Para cada grupo permitido
            If aUsrGrps[nX] == aGrupos[nY] // Se o grupo do usu�rio est� na lista de grupos permitidos
                //RestArea(aArea) // Restaura o contexto anterior
                Return  // Sai da fun��o imediatamente autorizando
            EndIf
        Next // Pr�ximo grupo permitido
    Next // Pr�ximo grupo do usu�rio


    FWAlertInfo("Filtra t�tulos E1_TIPO e Diferente de RES", "Aten��o APLICANDO O FILTRO")   
    DbSelectArea("SE2")   
    DbSetOrder(1)   
    DbSetFilter(bCondicao, "E2_TIPO <> 'RES'")

    //RestArea(aArea) // Restaura o contexto anterior
     
Return 
