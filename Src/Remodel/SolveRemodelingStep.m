function [Geo, Set, DidNotConverge]=SolveRemodelingStep(Geo_n, Geo, Dofs, Set)
    % This function solves local problem to obtain the position of the newly
    % remodeled vertices with prescribed settings (Set.***_LP), e.g.
    % Set.lambda_LP. 
    
    % Remark: The convergence strategy (regularization with viscosity) is 
    % initiated from the first iteration by setting (Set.nu_LP_Inital>Set.nu) 
    % and then it is reduced progressively. The solution is considered to be 
    % converged only when the prescribed value of global viscosity (Set.nu) is reached.
    
    fprintf('=====>> Solving Local Problem....\n');
    Geop=Geo;
    IncreaseEta=true;
    original_nu=Set.nu;
    
    Set.nu0=Set.nu;
    Set.nu=Set.nu_LP_Initial;
    Geo.Remodelling = true;
    Set.MaxIter=Set.MaxIter0/2;
    while 1
        [g,K, Geo]=KgGlobal(Geo_n, Geo, Set);
        
        dy=zeros((Geo.numF+Geo.numY)*3);
        dyr=norm(dy(Dofs.Remodel));
        gr=norm(g(Dofs.Remodel)); 
        fprintf('Local Problem ->Iter: %i, ||gr||= %.3e ||dyr||= %.3e  nu/nu0=%.3e  dt/dt0=%.3g \n',0,gr,dyr,Set.nu/Set.nu0,Set.dt/Set.dt0);
        [Geo, g, K, Energy, Set, gr, dyr, dy] = newtonRaphson(Geo_n, Geo, Dofs, Set, K, g, -1, -1);
        if IncreaseEta && (gr>Set.tol || dyr>Set.tol)
            fprintf('Convergence was not achieved ... \n');
            fprintf('First strategy ---> Restart iterating while higher viscosity... \n');
            Geo=Geop;
            Set.nu=Set.nu*10;
            Set.MaxIter=Set.MaxIter0*4;
            IncreaseEta=false;
        elseif gr>Set.tol || dyr>Set.tol || any(isnan(g(Dofs.Free))) || any(isnan(dy(Dofs.Free))) 
            % this should not take place
            fprintf('Local Problem did not converge after %i iterations.\n',Set.iter);
            Set.MaxIter=Set.MaxIter0;
            DidNotConverge=true;
            Set.nu=original_nu;
            break;
        else 
            Set.MaxIter=Set.MaxIter0;
            fprintf('=====>> Local Problem converged in %i iterations.\n',Set.iter);
            DidNotConverge=false;
            Set.nu=original_nu;
			Geo.Remodelling = false;
            break;
        end
    end 
end 