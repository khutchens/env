# vim: syntax=gdb

define freertos_task_print
    #echo freertos_task_print\r\n
    set $task = $arg0
    #if($task.xItemValue == (TickType_t)-1)
        #print $task
        #print *$task
        #print *(tskTCB*)$task->pvOwner
        if($task->pvOwner == pxCurrentTCB)
            echo CURRENT :
        else
            echo -       :
        end
        print (char*)((tskTCB*)$task->pvOwner)->pcTaskName

        # print TCB
        #print *((tskTCB*)$task->pvOwner)

        # print free stack space
        #print ((tskTCB*)$task->pvOwner)->pxTopOfStack - ((tskTCB*)$task->pvOwner)->pxStack

        # print stack bottom to check for possible overflow
        #print ((tskTCB*)$task->pvOwner)->pxStack[0]
        #print ((tskTCB*)$task->pvOwner)->pxStack[1]
        #print ((tskTCB*)$task->pvOwner)->pxStack[2]
        #print ((tskTCB*)$task->pvOwner)->pxStack[3]
    #end
end

define freertos_tasklist_traverse
    #echo freertos_tasklist_traverse\r\n
    set $tasklist = $arg0
    #print $tasklist
    set $count = $tasklist.uxNumberOfItems + 0
    #print $count
    set $task = $tasklist.pxIndex
    #set $taskend = $task
    set $taskend = $tasklist.xListEnd.pxPrevious.pxNext
    #if($task.pxNext != $task.pxPrevious)
    #while($task != $taskend)
    if($count > 0)
        set $end = 0
        #while($count > 0)
        while($end == 0)
            if($task != $taskend)
                freertos_task_print($task)
            end
            set $task = $task.pxNext
            #set $count = $count - 1
            if($task == $taskend)
                set $end = 1
            end
        end
    end
    #end
end

define freertos_tasks
    #echo freertos_tasks\r\n
    set $num_pri = sizeof(pxReadyTasksLists)/sizeof(List_t)

    while($num_pri >= 0)
        freertos_tasklist_traverse(pxReadyTasksLists[$num_pri])
        set $num_pri = $num_pri - 1
    end
    freertos_tasklist_traverse(xDelayedTaskList1)
    freertos_tasklist_traverse(xDelayedTaskList2)
    freertos_tasklist_traverse(xPendingReadyList)
    freertos_tasklist_traverse(xTasksWaitingTermination)
    freertos_tasklist_traverse(xSuspendedTaskList)
end
