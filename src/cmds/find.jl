
function initFind(ed::Editor)
    ed.params[:find] = Dict{Symbol, Any}()

    # 1 indexed, 0 none
    ed.params[:find][:last_match] = 0
    ed.params[:find][:direction] = 1
end


function findCallback(ed::Editor, query::String, key::Char)
    # If the params have not been created, init them
    if !(:find in keys(ed.params))
        initFind(ed)
    end

    last_match = ed.params[:find][:last_match]
    direction = ed.params[:find][:direction]

    if key == '\r' || key == '\x1b'
        last_match = 0
        direction = 1
        return
    elseif key == ARROW_RIGHT || key == ARROW_DOWN
        direction = 1
    elseif key == ARROW_LEFT || key == ARROW_UP
        direction = -1
    else
        last_match = 0
        direction = 1
    end

    last_match == 0 && (direction = 1)
    current = last_match
    for i = 1:length(ed.rows)
        current += direction

        # Bounds check
        if current == 0
            # At begenning of document? Go to end
            current = length(ed.rows)
        elseif current == length(ed.rows)+1
            # At end of doc? Got to start
            current = 1
        end

        row = ed.rows[current]
        loc = search(row.chars, query)
        if loc != 0:-1
            last_match = current
            ed.csr.y = current
            ed.csr.x = first(loc)#charX(row, first(loc))
            ed.rowoff = length(ed.rows)
            break
        end
    end

    # Update params
    ed.params[:find][:last_match] = last_match
    ed.params[:find][:direction] = direction

end

function editorFind(ed::Editor, str::String)
    saved_cx, saved_cy = ed.csr.x, ed.csr.y
    saved_coloff = ed.coloff
    saved_rowoff = ed.rowoff

    findCallback(ed, str, ' ')
    query = editorPrompt(ed, "Search (arrow keys for next/prev): ",
                         callback=findCallback,
                         buf=str,
                         showcursor=false)

    # If the user cancels the search, restore view
    if query == ""
        ed.csr.x = saved_cx
        ed.csr.y = saved_cy
        ed.coloff = saved_coloff
        ed.rowoff = saved_rowoff
    end
end


addCommand(:find, editorFind,
    help="type to find, <enter> to get cursor, arrow keys to next/prev")
