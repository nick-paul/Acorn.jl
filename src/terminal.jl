import Base.==

@enum(Key,
    BACKSPACE = (@static Sys.iswindows() ? 8 : 127),
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
	term = REPL.Terminals.TTYTerminal(get(ENV, "TERM", @static Sys.iswindows() ? "" : "dumb"), Base.stdin, Base.stdout, Base.stderr)
	REPL.Terminals.raw!(term, true)
	c = readNextChar()
	print("Code: $(UInt32(c)), Char: $(Char(c))")
	REPL.Terminals.raw!(term, true)
	return nothing
end

readNextChar() = Char(read(Base.stdin,1)[1])

function readKey() ::UInt32
    c = readNextChar()

    # Escape characters
    if c == '\x1b'
        Base.stdin.buffer.size < 3 && return '\x1b'
        esc_a = readNextChar()
        esc_b = readNextChar()

        if esc_a == '['
            if esc_b >= '0' && esc_b <= '9'
                Base.stdin.buffer.size < 4 && return '\x1b'
                esc_c = readNextChar()

                if esc_c == '~'
                    if esc_b == '1'
                        return UInt32(HOME_KEY)
                    elseif esc_b == '4'
                        return UInt32(END_KEY)
                    elseif esc_b == '3'
                        return UInt32(DEL_KEY)
                    elseif esc_b == '5'
                        return UInt32(PAGE_UP)
                    elseif esc_b == '6'
                        return UInt32(PAGE_DOWN)
                    elseif esc_b == '7'
                        return UInt32(HOME_KEY)
                    elseif esc_b == '8'
                        return UInt32(END_KEY)
                    else
                        return UInt32('\x1b')
                    end
                elseif esc_c == ';'
                    Base.stdin.buffer.size < 6 && return '\x1b'
                    esc_d = readNextChar()
                    esc_e = readNextChar()

                    if esc_d == '2'
                        # shift + arrorw
                        if esc_e == 'A'
                            return UInt32(S_ARROW_UP)
                        elseif esc_e == 'B'
                            return UInt32(S_ARROW_DOWN)
                        elseif esc_e == 'C'
                            return UInt32(S_ARROW_RIGHT)
                        elseif esc_e == 'D'
                            return UInt32(S_ARROW_LEFT)
                        else
                            return UInt32('\x1b')
                        end
                    elseif esc_d == '5'
                        # Ctrl + arrow
                        if esc_e == 'A'
                            return UInt32(C_ARROW_UP)
                        elseif esc_e == 'B'
                            return UInt32(C_ARROW_DOWN)
                        elseif esc_e == 'C'
                            return UInt32(C_ARROW_RIGHT)
                        elseif esc_e == 'D'
                            return UInt32(C_ARROW_LEFT)
                        else
                            return UInt32('\x1b')
                        end
                    end
                end
            else
                # Arrow keys
                if esc_b == 'A'
                    return UInt32(ARROW_UP)
                elseif esc_b == 'B'
                    return UInt32(ARROW_DOWN)
                elseif esc_b == 'C'
                    return UInt32(ARROW_RIGHT)
                elseif esc_b == 'D'
                    return UInt32(ARROW_LEFT)
                elseif esc_b == 'H'
                    return UInt32(HOME_KEY)
                elseif esc_b == 'F'
                    return UInt32(END_KEY)
                else
                    return UInt32('\x1b')
                end
            end
        elseif esc_a == 'O'
            if esc_a == 'H'
                return UInt32(HOME_KEY)
            elseif esc_a == 'F'
                return UInt32(END_KEY)
            end
        end

        return UInt32('\x1b')
    else
        return UInt32(c;)
    end
end
