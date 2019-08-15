--Random {seed=1234567}

Fire = Model {
    dim         = 50,
    finalTime   = 100,
    neighbor="vonneumann", --"vonneumann" ou "moore"
    p=0.1,
    prob=0.9,
    init = function(model)
        model.cell = Cell{
            state = Random{forest=model.p,empty= 1-model.p},
            execute = function(cell)
                if cell.state == "forest" then
                    forEachNeighbor(cell, function(neighbor)
                            if neighbor.past.state == "burning" then
                                cell.state = "burning"
                            end
                        end)

                elseif cell.state == "burning" then
                    if Random():number()< model.prob then
                        cell.state = "burned"
                    end
                end
            end
        }
        model.cs = CellularSpace{
            xdim = model.dim,
            --dim = model.dim,
            instance = model.cell
        }
        model.cs:createNeighborhood{strategy = model.neighbor}
        model.cs:sample().state = "burning"

        model.map = Map{
            target = model.cs,
            select = "state",
            value  = {"forest", "burning", "burned","empty"},
            color = {"green", "red", "brown", "white"}
        }


        model.timer = Timer {
            Event{action = model.map},
            Event{action = model.cs}
        }
    end -- fecha init
} -- fecha Model

--fire=Fire{}
--fire:run()
--print(#fire.cs:split("state").forest)
--[[for i=0,1,0.1 do
     fire=Fire{p=i}
     fire:run()
     print(#fire.cs:split("state").forest)
    end--]]

import("calibration")

mr=MultipleRuns{
    model=Fire,
    repetition=50,
    parameters= {
        p=Choice{min=0.1, max=0.9, step=0.1}

    },
    forest=function(model)
        return #model.cs:split("state").forest
    end

}
file=File("file_test.csv")
file:write(mr.output, ";")
