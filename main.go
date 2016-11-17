package main
import (
        "fmt"
        "net/http"
        "os"
)
func handler(w http.ResponseWriter, r *http.Request) {
        h, _ := os.Hostname()
        fmt.Fprintf(w, "Hi there, I'm served from %s!", h)
        for _, e := range os.Environ() {
            pair := strings.Split(e, "=")
                fmt.Println(pair[0],": ", pair[1])
    }
}
func main() {
        http.HandleFunc("/", handler)
        http.ListenAndServe(":8484", nil)
}
