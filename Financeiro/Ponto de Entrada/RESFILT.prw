#include 'totvs.ch'

User Function RESFILT

    LOCAL aGrupos       := StrTokArr(AllTrim(GetMV("SM_XGRRES")),";")
    LOCAL aUsrGrps      := UsrRetGrp()
    Local bCondicao     := {||E2_TIPO <> 'RES'}
   // Local lContinua     := .F.
    Local nX            := 0
    Local nY            := 0

    For nX := 1 To Len(aUsrGrps) // Para cada grupo do usuário
        For nY := 1 To Len(aGrupos) // Para cada grupo permitido
            If aUsrGrps[nX] == aGrupos[nY] // Se o grupo do usuário está na lista de grupos permitidos
                //RestArea(aArea) // Restaura o contexto anterior
                Return  // Sai da função imediatamente autorizando
            EndIf
        Next // Próximo grupo permitido
    Next // Próximo grupo do usuário


    FWAlertInfo("Filtra títulos E1_TIPO e Diferente de RES", "Atenção APLICANDO O FILTRO")   
    DbSelectArea("SE2")   
    DbSetOrder(1)   
    DbSetFilter(bCondicao, "E2_TIPO <> 'RES'")

    //RestArea(aArea) // Restaura o contexto anterior
     
Return 
