module FileSessionAdapter

using Sessions, Genie, Logger, Configuration, App

const SESSION_FOLDER = IS_IN_APP ? App.config.session_folder : tempdir()

"""
    write(session::Sessions.Session) :: Sessions.Session

Persists the `Session` object to the file system, using the configured sessions folder and returns it.
"""
function write(session::Sessions.Session) :: Sessions.Session
  if isempty(session.id)
    Logger.log("Invalid session ID", :err)
    Logger.log("Can't write session", :err)
    Logger.log("$(@__FILE__):$(@__LINE__)", :err)

    return session
  end

  try
    open(joinpath(SESSION_FOLDER, session.id), "w") do (io)
      serialize(io, session)
    end
  catch ex
    Logger.log("Error when serializing session $(escape_string(session)) in $(@__FILE__):$(@__LINE__)", :err)
    Logger.log(string(ex), :err)
    Logger.log("$(@__FILE__):$(@__LINE__)", :err)

    rethrow(ex)
  end

  session
end


"""
    read(session_id::Union{String,Symbol}) :: Nullable{Sessions.Session}
    read(session::Sessions.Session) :: Nullable{Sessions.Session}

Attempts to read from file the session object serialized as `session_id`.
"""
function read(session_id::Union{String,Symbol}) :: Nullable{Sessions.Session}
  if isempty(session_id)
    Logger.log("Invalid session ID", :err)
    Logger.log("Can't read session", :err)
    Logger.log("$(@__FILE__):$(@__LINE__)", :err)

    return Nullable{Sessions.Session}()
  end

  try
    isfile(joinpath(SESSION_FOLDER, session_id)) || return Nullable{Sessions.Session}()
  catch ex
    Logger.log("Can't check session file", :err)
    Logger.log(string(ex), :err)
    Logger.log("$(@__FILE__):$(@__LINE__)", :err)

    Nullable{Sessions.Session}()
  end

  try
    session = open(joinpath(SESSION_FOLDER, session_id), "r") do (io)
      deserialize(io)
    end

    Nullable{Sessions.Session}(session)
  catch ex
    Logger.log("Can't read session", :err)
    Logger.log(string(ex), :err)
    Logger.log("$(@__FILE__):$(@__LINE__)", :err)

    Nullable{Sessions.Session}()
  end
end
function read(session::Sessions.Session) :: Nullable{Sessions.Session}
  read(session.id)
end

end
