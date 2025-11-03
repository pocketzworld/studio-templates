--!SerializeField
local TaskBar : GameObject = nil
--!SerializeField
local Tasks : number = nil

tasksCompleted = IntValue.new("TasksCompleted")
local totalTasks = IntValue.new("TotalTasks")
local updateTaskCountRequest = Event.new("UpdateTaskCountRequest")

taskResetEvent = Event.new("TaskResetEvent")
resetTaskNumRequest = Event.new("ResetTaskNumRequest")
setTotalTasksRequest = Event.new("SetTotalTasksRequest")


function self:ClientAwake()

    local TotalTasks = Tasks
    local FinishedTasks = 0
    TaskBar.transform.localScale = Vector3.new(0,1,1)

    totalTasks.Changed:Connect(function(newVal, oldVal)
        TotalTasks = newVal
    end)

    function UpdateTaskCount()
        updateTaskCountRequest:FireServer()
    end

    function SetTotals(x)
        setTotalTasksRequest:FireServer(x)
    end

    tasksCompleted.Changed:Connect(function(newVal, oldVal)
        FinishedTasks = newVal
        if(FinishedTasks <= TotalTasks) then
            TaskBar.transform.localScale = Vector3.new((FinishedTasks/TotalTasks),1,1)
        end
    end)

    function ResetTasks()
        resetTaskNumRequest:FireServer()
    end
end

function self:ServerAwake()
    totalTasks.value = Tasks
    print(tostring(totalTasks.value))
    updateTaskCountRequest:Connect(function()
        tasksCompleted.value = tasksCompleted.value + 1
        if(tasksCompleted.value >= totalTasks.value)then
            -- All Tasks Completed
            print("Crew Wins")
            taskResetEvent:FireAllClients()
        end 
    end)

    resetTaskNumRequest:Connect(function()
        print("RRRREEEESSSEEETT")
        tasksCompleted.value = 0
    end)
    setTotalTasksRequest:Connect(function(player,x)
        totalTasks.value = x
        print("Total Tasks: " .. tostring(totalTasks.value))
    end)
end