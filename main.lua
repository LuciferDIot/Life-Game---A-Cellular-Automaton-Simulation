-- Set up display
local display = require("display")
local widget = require("widget")

-- Constants
local gridSize = 5
local cellSize = 50  -- Adjust this size as needed
local spacing = 10   -- Adjust the spacing between cells
local buttonWidth = 100
local buttonHeight = 40

-- Create a group to hold all display objects
local sceneGroup = display.newGroup()

-- Create a group to hold the grid cells
local gridGroup = display.newGroup()

-- Function to handle cell selection
local function cellTapped(event)
    local cell = event.target

    if not isSimulationRunning then
        if cell.selected then
            -- Change the cell's color back to white when deselected
            cell:setFillColor(1, 1, 1)  -- White color
            cell.selected = false
        else
            -- Change the cell's color to dark when selected
            cell:setFillColor(0, 0, 0)
            cell.selected = true
        end
    end
end

-- Create the grid
local grid = {}
for row = 1, gridSize do
    grid[row] = {}
    for col = 1, gridSize do
        local cell = display.newRect(
            (col - 1) * (cellSize + spacing),
            (row - 1) * (cellSize + spacing),
            cellSize,
            cellSize
        )

        cell.anchorX = 0
        cell.anchorY = 0
        cell:setFillColor(1, 1, 1)  -- White color
        cell.strokeWidth = 2
        cell:setStrokeColor(0, 0, 0)

        cell.selected = false  -- Custom flag to track cell selection

        cell:addEventListener("tap", cellTapped)

        grid[row][col] = cell
        gridGroup:insert(cell)
    end
end

-- Calculate the total width and height of the grid
local gridWidth = gridSize * (cellSize + spacing) - spacing
local gridHeight = gridSize * (cellSize + spacing) - spacing

-- Position the grid group at the center of the screen
gridGroup.x = display.contentCenterX - gridWidth / 2
gridGroup.y = display.contentCenterY - gridHeight / 2

-- Declare the "Start" button
local startButton
local isSimulationRunning

-- Function to calculate the next generation
local function calculateNextGeneration()
    local newGrid = {}
    for row = 1, gridSize do
        newGrid[row] = {}
        for col = 1, gridSize do
            local neighbors = 0
            for i = -1, 1 do
                for j = -1, 1 do
                    if i ~= 0 or j ~= 0 then
                        local x = (row + i - 1 + gridSize) % gridSize + 1
                        local y = (col + j - 1 + gridSize) % gridSize + 1
                        if grid[x][y].selected then
                            neighbors = neighbors + 1
                        end
                    end
                end
            end

            if grid[row][col].selected then
                -- Cell is alive
                if neighbors < 2 or neighbors > 3 then
                    newGrid[row][col] = false  -- Cell dies
                else
                    newGrid[row][col] = true  -- Cell stays alive
                end
            else
                -- Cell is dead
                if neighbors == 3 then
                    newGrid[row][col] = true  -- Cell becomes alive
                else
                    newGrid[row][col] = false  -- Cell stays dead
                end
            end
        end
    end

    -- Update the grid
    for row = 1, gridSize do
        for col = 1, gridSize do
            grid[row][col].selected = newGrid[row][col]
            if newGrid[row][col] then
                grid[row][col]:setFillColor(0, 0, 0)  -- Alive cell color (black)
            else
                grid[row][col]:setFillColor(1, 1, 1)  -- Dead cell color (white)
            end
        end
    end
end

-- Function to update the grid in each iteration
local function updateGrid()
    if isSimulationRunning then
        calculateNextGeneration()
        timer.performWithDelay(2000, updateGrid)  -- Adjust the delay as needed
    end
end

-- Create the "Start" button
startButton = widget.newButton({
    width = buttonWidth,
    height = buttonHeight,
    label = "Start",
    onRelease = function()
        if isSimulationRunning then
            -- Stop the simulation if it's already running
            isSimulationRunning = false
            startButton:setLabel("Start")
        else
            -- Start the simulation
            isSimulationRunning = true
            startButton:setLabel("Stop")

            -- Start the grid update loop
            updateGrid()
        end
    end
})

startButton.x = display.contentCenterX
startButton.y = display.contentHeight - buttonHeight / 2 - 10  -- Adjust the Y position as needed

sceneGroup:insert(startButton)

-- Function to handle app exit or scene cleanup
local function onExit(event)
    if event.phase == "will" then
        -- Stop any running timers, transitions, or audio here
        if isSimulationRunning then
            isSimulationRunning = false
        end
    end
end

-- Add an exit event listener
Runtime:addEventListener("system", onExit)
