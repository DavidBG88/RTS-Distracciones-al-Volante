package Actuators is
    task Riesgos is
        pragma Priority (50);
    end Riesgos;
    task Display is
        pragma Priority (10);
    end Display;
end Actuators;
