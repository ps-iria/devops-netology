package main

import "fmt"

func main() {
	fmt.Print("Ведите длину в метрах: ")
	var input float64
	fmt.Scanf("%f", &input)

	output := input / 0.3048

	fmt.Println(input, "м, в футах =", output)
}
