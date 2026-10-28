package main

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
)

// Definisci qui il tuo header personalizzato
const headerTemplate = `/*
 * penguins-eggs - Copyright (C) 2017-%d Piero Proietti
 * Author: Piero Proietti <piero.proietti@gmail.com>
 * https://penguins-eggs.net
 *
 * This file is part of penguins-eggs.
 * Released under the GNU GPL v3 license.
 */

`

func main() {
	// Anno corrente dinamico o fisso
	currentYear := 2026
	header := fmt.Sprintf(headerTemplate, currentYear)

	// Cartella di partenza (la directory corrente del monorepo)
	root := "."

	updatedCount := 0
	skippedCount := 0

	err := filepath.WalkDir(root, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// Salta la cartella .git, le dipendenze di vendor o build esterne se presenti
		if d.IsDir() && (d.Name() == ".git" || d.Name() == "vendor" || d.Name() == "dist") {
			return filepath.SkipDir
		}

		// Consideriamo solo i file sorgente Go (.go)
		if !d.IsDir() && strings.HasSuffix(d.Name(), ".go") {
			content, err := os.ReadFile(path)
			if err != nil {
				fmt.Printf("Errore lettura file %s: %v\n", path, err)
				return nil
			}

			contentStr := string(content)

			// Controlla se il file ha già l'header (cerchiamo una chiave univoca come "penguins-eggs")
			if strings.Contains(contentStr, "penguins-eggs") {
				skippedCount++
				return nil
			}

			// Prepariamo il nuovo contenuto inserendo l'header in cima
			newContent := header + contentStr

			// Scriviamo il file aggiornato
			err = os.WriteFile(path, []byte(newContent), 0644)
			if err != nil {
				fmt.Printf("Errore scrittura file %s: %v\n", path, err)
				return nil
			}

			fmt.Printf("[AGGIORNATO] %s\n", path)
			updatedCount++
		}

		return nil
	})

	if err != nil {
		fmt.Printf("Errore durante la scansione delle directory: %v\n", err)
		return
	}

	fmt.Println("\n----------------------------------------")
	fmt.Printf("Scansione completata!\n")
	fmt.Printf("File aggiornati con l'header: %d\n", updatedCount)
	fmt.Printf("File già provvisti di header: %d\n", skippedCount)
}