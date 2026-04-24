using HTTP
using JSON3

# Verificación de API key
if !haskey(ENV, "OPENAI_API_KEY") || isempty(ENV["OPENAI_API_KEY"])
    error("No se encontró OPENAI_API_KEY")
end

println(" API Key detectada correctamente")

url = "https://api.openai.com/v1/chat/completions"

body = Dict(
    "model" => "gpt-5.4-mini",
    "temperature" => 0.7,
    "messages" => [
        Dict("role" => "system", "content" => "1. Eres un experto docente de Estadistica. 2. Evita Alucinar."),
        Dict("role" => "user",   "content" => "Hola, Me podrias explicar de forma facil y clara la diferencia entre la varianza y covarianza.")
    ]
)

try
    println("\nEnviando solicitud a OpenAI...")

    response = HTTP.post(
        url,
        headers = [
            "Content-Type" => "application/json",
            "Authorization" => "Bearer $(ENV["OPENAI_API_KEY"])"
        ],
        body = JSON3.write(body)
    )

    result = JSON3.read(response.body)
    respuesta = result.choices[1].message.content

    println("\n ¡Éxito! Respuesta de OpenAI:")
    println(respuesta)

catch e
    println("\n Error: ", typeof(e))
    showerror(stdout, e)
end