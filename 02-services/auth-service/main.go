package main

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	"os"
	"time"

	_ "github.com/jackc/pgx/v4/stdlib"
	"github.com/joho/godotenv"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

// App struct (para injeção de dependência)
type App struct {
	DB        *sql.DB
	MasterKey string
}

func main() {
	// Carrega o .env para desenvolvimento local. Em produção, isso não fará nada.
	_ = godotenv.Load()

	tracerProvider, err := initTracerProvider(context.Background())
	if err != nil {
		log.Fatalf("Não foi possível inicializar OpenTelemetry: %v", err)
	}

	defer func() {
		shutdownCtx, cancel := context.WithTimeout(
			context.Background(),
			5*time.Second,
		)
		defer cancel()

		if err := tracerProvider.Shutdown(shutdownCtx); err != nil {
			log.Printf(
				"Erro ao finalizar OpenTelemetry: %v",
				err,
			)
		}
	}()

	log.Println("OpenTelemetry inicializado com sucesso")

	// --- Configuração ---
	port := os.Getenv("PORT")
	if port == "" {
		port = "8001" // Porta padrão
	}

	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		log.Fatal("DATABASE_URL deve ser definida")
	}

	masterKey := os.Getenv("MASTER_KEY")
	if masterKey == "" {
		log.Fatal("MASTER_KEY deve ser definida")
	}

	// --- Conexão com o Banco ---
	db, err := connectDB(databaseURL)
	if err != nil {
		log.Fatalf("Não foi possível conectar ao banco de dados: %v", err)
	}
	defer func() {
		if err := db.Close(); err != nil {
			log.Printf("erro ao fechar conexão com banco")
		}
	}()

	app := &App{
		DB:        db,
		MasterKey: masterKey,
	}

	// --- Rotas da API ---
	mux := http.NewServeMux()
	mux.HandleFunc("/health", app.healthHandler)

	// Endpoint público para validar uma chave
	mux.HandleFunc("/validate", app.validateKeyHandler)

	// Endpoints de "admin" para criar/gerenciar chaves
	// Eles são protegidos pelo middleware de autenticação
	mux.Handle("/admin/keys", app.masterKeyAuthMiddleware(http.HandlerFunc(app.createKeyHandler)))

	log.Printf("Serviço de Autenticação (Go) iniciado")
	server := &http.Server{
		Addr:         ":" + port,
		Handler:      otelhttp.NewHandler(mux, "auth-service"),
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}
	if err := server.ListenAndServe(); err != nil {
		log.Fatal(err)
	}

}

// connectDB inicializa e testa a conexão com o PostgreSQL
func connectDB(databaseURL string) (*sql.DB, error) {
	db, err := sql.Open("pgx", databaseURL)
	if err != nil {
		return nil, err
	}

	if err = db.Ping(); err != nil {
		return nil, err
	}

	log.Println("Conectado ao PostgreSQL com sucesso!")
	return db, nil
}
