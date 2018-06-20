function denstrat_1class()
    % 

    % Sub Initialize()
    dzeta = (1 - zetar) / nintervals;
    for i = 1:nintervals+1
        zeta(i, 1) = zetar + dzeta * (i - 1);
        Ri(i) = 0;
        Fstrat(i) = 1;
    end
    Converges = false;
    Bombs = false;
    n = 0;
    un(1) = unr;
    cn(1) = 1;
    intc(1) = 0;
    
    [un, cn, unold, cnold, Ri, Fstrat] = ComputeUCnormal(n, nintervals, un, cn, kappa, zeta, Fstrat, dzeta, intc, ustarr, Ristar);
    ui = un;
    ci = cn;
    
    figure()
    while ~or(Bombs, Converges)
        n = n + 1;
        [un, cn, unold, cnold, Ri, Fstrat] = ComputeUCnormal(n, nintervals, un, cn, kappa, zeta, Fstrat, dzeta, intc, ustarr, Ristar);
        [Bombs, Converges] = CheckConvergence(n, nintervals, un, cn, unold, cnold, Ep, nmax);
        
        subplot(1, 2, 1)
            plot(un, zeta)
        subplot(1, 2, 2)
            plot(cn, zeta)
        drawnow
    end
    
    Rou = vs/kappa*ustar;
    c0 = 1 .* ( ((1-zeta)./zeta) ./ ((1 - zetar) / zetar) ) .^ Rou;

    if Bombs
        error('no convergence')
    else
        figure()
        subplot(1, 2, 1); hold on;
            plot(ustar.*ui/100, H.*zeta)
            plot(ustar.*un/100, H.*zeta)
        subplot(1, 2, 2); hold on;
            plot(Cr.*ci, H.*zeta)    
            plot(Cr.*cn, H.*zeta)
            legend('no strat', 'strat')
    end



end

function [un, cn, unold, cnold, Ri, Fstrat] = ComputeUCnormal(n, nintervals, un, cn, kappa, zeta, Fstrat, dzeta, intc, ustarr, Ristar)

    if n > 0
        for i = 1:nintervals + 1
            unold(i) = un(i);
            cnold(i) = cn(i);
        end
    else
        unold = un;
        cnold = cn;
    end
    for i = 2:nintervals + 1
        ku1 = 1 / (kappa * zeta(i - 1) * Fstrat(i - 1));
        ku2 = 1 / (kappa * zeta(i) * Fstrat(i));
        un(i) = un(i - 1) + 0.5 * (ku1 + ku2) * dzeta;
        kc1 = 1 / ((1 - zeta(i - 1)) * zeta(i - 1) * Fstrat(i - 1));
        kc2 = 1 / ((1 - zeta(i)) * zeta(i) * Fstrat(i));
        intc(i) = intc(i - 1) + 0.5 * (kc1 + kc2) * dzeta;
        cn(i) = exp(-1 / kappa / ustarr * intc(i));
    end
    una = 0.5 * dzeta * (un(1) + un(nintervals + 1));
    cna = 0.5 * dzeta * (cn(1) + cn(nintervals + 1));
    qs = 0.5 * dzeta * (un(1) * cn(1) + un(nintervals + 1) * cn(nintervals + 1));
    for i = 2:nintervals + 1
        una = una + dzeta * un(i);
        cna = cna + dzeta * cn(i);
        qs = qs + dzeta * un(i) * cn(i);
    end
    for i = 1:nintervals + 1
        Ri(i) = Ristar * (kappa * zeta(i) * Fstrat(i)) / (ustarr * (1 - zeta(i))) * cn(i);
        X = 1.35 * Ri(i) / (1 + 1.35 * Ri(i));
        Fstrat(i) = 1 / (1 + 10 * X);
    end

end

function [Bombs, Converges] = CheckConvergence(n, nintervals, un, cn, unold, cnold, Ep, nmax)
             
%     Dim Error As Single: Dim ern As Single: Dim erc As Single
%     Dim i As Integer
    if n > 0
        Error = 0;
        for i = 1:nintervals
            ern = abs(2 * (un(i) - unold(i)) / (un(i) + unold(i)));
            erc = abs(2 * (cn(i) - cnold(i)) / (cn(i) + cnold(i)));
            if ern > Error
                Error = ern;
            end
            if erc > Error
                Error = erc;
            end
        end
        if Error < Ep
            Converges = true;
            Bombs = false;
        else
            Converges = false;
            if n >= nmax
                Bombs = true;
            else
                Bombs = false;
            end
        end
%         If Error < Ep Then
%             Converges = True
%         Else
%             If n >= nmax Then Bombs = True
%         End If
%     End If
    end
% End Sub
end

% 
% Rem Attribute VBA_ModuleType=VBAModule
% Option VBASupport 1
% Private c As Single
% Const zetar = 0.05
% Const nintervals = 50
% Const kappa = 0.4
% Const g = 981
% Const Ep = 0.001
% Const nmax = 200
% Private ustarr As Single: Private dzeta As Single: Private qs As Single
% Private una As Single: Private cna As Single:
% Private unr As Single: Private Ristar As Single
% Private un(100) As Single: Private cn(100) As Single: Private zeta(100) As Single
% Private unold(100) As Single: Private cnold(100) As Single
% Private Fstrat(100) As Single: Private Ri(100) As Single: Private intc(100) As Single
% Private n As Integer
% Private Converges As Boolean: Private Bombs As Boolean
% Private nchoice As Integer
% 
% Sub ClearAll()
%         Range(Cells(26, 1), Cells(76, 6)).Select
%         Selection.ClearContents
%         Range(Cells(39, 6), Cells(40, 12)).Select
%         Selection.ClearContents
%         Range(Cells(16, 12), Cells(17, 17)).Select
%         Selection.ClearContents
%         Range(Cells(19, 7), Cells(19, 7)).Select
%         Selection.ClearContents
%         Range(Cells(9, 10), Cells(9, 10)).Select
% End Sub
% 
% Sub Choice()
%     nchoice = Worksheets(2).Cells(1, 21).Value
%     Range(Cells(20, 7), Cells(20, 7)).Select
%     Selection.ClearContents
%     If nchoice = 1 Then
%         Worksheets(2).Range(Cells(19, 7), Cells(19, 7)).Select
%         Selection.ClearContents
%         Worksheets(2).Cells(16, 10).Value = "Specify reference volume concentration"
%         Worksheets(2).Range(Cells(17, 13), Cells(17, 17)).Select
%         Selection.ClearContents
%         Worksheets(2).Range(Cells(16, 16), Cells(16, 16)).Select
%     Else
%         Worksheets(2).Cells(16, 10).Value = "Specify a shear velocity due to skin friction in cm/s"
%         Worksheets(2).Range(Cells(16, 17), Cells(16, 16)).Select
%     End If
% End Sub
%     
% 

% 
% Sub WriteBase()
%     Dim i As Integer
%     For i = 1 To nintervals + 1
%         Worksheets(2).Cells(25 + i, 2).Value = un(i)
%         Worksheets(2).Cells(25 + i, 3).Value = cn(i)
%     Next i
%     If n = 0 Then
%         Worksheets(2).Cells(39, 7).Value = una
%         Worksheets(2).Cells(39, 8).Value = cna
%         Worksheets(2).Cells(39, 9).Value = qs
%     End If
% 
% End Sub
%
%         
% Sub WriteAnswer()
%     Dim i As Integer
%     For i = 1 To nintervals + 1
%         Worksheets(2).Cells(25 + i, 4).Value = un(i)
%         Worksheets(2).Cells(25 + i, 5).Value = cn(i)
%         Worksheets(2).Cells(25 + i, 6).Value = Ri(i)
%     Next i
%     If n > 0 Then
%         Worksheets(2).Cells(39, 10).Value = una
%         Worksheets(2).Cells(39, 11).Value = cna
%         Worksheets(2).Cells(39, 12).Value = qs
%     End If
%     Worksheets(2).Cells(40, 7).Value = "Number of iterations required = "
%     Worksheets(2).Cells(40, 10).Value = n
%     Range(Cells(41, 7), Cells(41, 7)).Select
% End Sub
% 
% Sub Sing()
%     Worksheets(2).Range(Cells(26, 4), Cells(76, 6)).Select
%     Selection.ClearContents
%     Worksheets(2).Range(Cells(39, 7), Cells(39, 12)).Select
%     Selection.ClearContents
%     Worksheets(2).Cells(26, 4).Value = "Calculation failed to converge"
% End Sub
% 
% 
% 
