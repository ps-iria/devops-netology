package main

import "fmt"

func main() {
	mas := []int{}

	for x := 1; x <= 100; x++ {
		if x%3 == 0 {
			mas = append(mas, x)
		}
	}

	fmt.Println(mas)
}
