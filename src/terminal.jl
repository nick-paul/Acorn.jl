import Base.==

@enum(Key,
    BACKSPACE = (@static is_windows() ? 8 : 127),
    ARROW_LEFT = 1000,
    ARROW_RIGHT,
    ARROW_UP,
    ARROW_DOWN,
    DEL_KEY,
    HOME_KEY,
    END_KEY,
    PAGE_UP,
    PAGE_DOWN,
    S_ARROW_UP,
    S_ARROW_DOWN,
    S_ARROW_LEFT,
    S_ARROW_RIGHT,
    C_ARROW_UP,
    C_ARROW_DOWN,
    C_ARROW_LEFT,
    C_ARROW_RIGHT)

==(c::UInt32, k::Key) = c == UInt32(k)
==(k::Key, c::UInt32) = c == UInt32(k)
==(c::Char, k::Key) = UInt32(c) == UInt32(k)
==(k::Key, c::Char) = UInt32(c) == UInt32(k)

ctrl_key(c::Char)::UInt32 = UInt32(c) & 0x1f

# For debugging
function printNextKey()
	term = Base.Terminals.TTYTerminal(get(ENV, "TERM", @static is_windows() ? "" : "dumb"), STDIN, STDOUT, STDERR)
	Base.Terminals.raw!(term, true)
	c = readNextChar()
	print("Code: $(UInt32(c)), Char: $(Char(c))")
	Base.Terminals.raw!(term, true)
	return nothing
end

readNextChar() = Char(read(STDIN,1)[1])

function readKey() ::UInt32
    c = readNextChar()

    # Escape characters
    if c == '\x1b'
        STDIN.buffer.size < 3 && return '\x1b'
        esc_a = readNextChar()
        esc_b = readNextChar()

        if esc_a == '['
            if esc_b >= '0' && esc_b <= '9'
                STDIN.buffer.size < 4 && return '\x1b'
                esc_c = readNextChar()

                if esc_c == '~'
                    if esc_b == '1'
                        return HOME_KEY
                    elseif esc_b == '4'
                        return END_KEY
                    elseif esc_b == '3'
                        return DEL_KEY
                    elseif esc_b == '5'
                        return PAGE_UP
                    elseif esc_b == '6'
                        return PAGE_DOWN
                    elseif esc_b == '7'
                        return HOME_KEY
                    elseif esc_b == '8'
                        return END_KEY
                    else
                        return '\x1b'
                    end
                elseif esc_c == ';'
                    STDIN.buffer.size < 6 && return '\x1b'
                    esc_d = readNextChar()
                    esc_e = readNextChar()

                    if esc_d == '2'
                        # shift + arrorw
                        if esc_e == 'A'
                            return S_ARROW_UP
                        elseif esc_e == 'B'
                            return S_ARROW_DOWN
                        elseif esc_e == 'C'
                            return S_ARROW_RIGHT
                        elseif esc_e == 'D'
                            return S_ARROW_LEFT
                        else
                            return '\x1b'
                        end
                    elseif esc_d == '5'
                        # Ctrl + arrow
                        if esc_e == 'A'
                            return C_ARROW_UP
                        elseif esc_e == 'B'
                            return C_ARROW_DOWN
                        elseif esc_e == 'C'
                            return C_ARROW_RIGHT
                        elseif esc_e == 'D'
                            return C_ARROW_LEFT
                        else
                            return '\x1b'
                        end
                    end
                end
            else
                # Arrow keys
                if esc_b == 'A'
                    return ARROW_UP
                elseif esc_b == 'B'
                    return ARROW_DOWN
                elseif esc_b == 'C'
                    return ARROW_RIGHT
                elseif esc_b == 'D'
                    return ARROW_LEFT
                elseif esc_b == 'H'
                    return HOME_KEY
                elseif esc_b == 'F'
                    return END_KEY
                else
                    return '\x1b'
                end
            end
        elseif esc_a == 'O'
            if esc_a == 'H'
                return HOME_KEY
            elseif esc_a == 'F'
                return END_KEY
            end
        end

        return '\x1b'
    else
        return c;
    end
end
