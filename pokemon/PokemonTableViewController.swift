//
//  PokemonTableViewController.swift
//  pokemon
//
//  Created by Anika Morris on 6/26/20.
//  Copyright © 2020 Anika Morris. All rights reserved.
//

import Foundation
import UIKit

class PokemonTableViewController: UITableViewController {
    
    var pokemonList: [Pokemon] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var nextUrl: String = "https://pokeapi.co/api/v2/pokemon/"

    override func viewDidLoad() {
        super.viewDidLoad()

        getPokemon(url: nextUrl) { pokemons, url in
            self.pokemonList = pokemons
            self.nextUrl = url
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonCell", for: indexPath) as! PokemonCell
        cell.nameLabel.text = pokemonList[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        getPokemon(url: nextUrl) { pokemons, url in
            self.pokemonList.append(contentsOf: pokemons)
            self.nextUrl = url
        }
    }
    
    func getPokemon(url: String, completion: @escaping ([Pokemon], String) -> Void) {
        let defaultSession = URLSession(configuration: .default)
        guard let url = URL(string: url) else { return }
        let request = URLRequest(url: url)
        let dataTask = defaultSession.dataTask(with: request) { data, response, error in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
        
            guard let data = data else {
                print("no data")
                return
            }
            
            var thisPokemonList: [Pokemon] = []
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                
                guard let results = jsonObject?.value(forKey: "results") as? NSArray else { return }
                guard let nextURL = jsonObject?.value(forKey: "next") as? String else {
                    print("couldn't find next url")
                    return
                }
                for pokemonDict in results {
                    let dict = pokemonDict as! NSDictionary
                    guard let name = dict.value(forKey: "name") as? String else {
                        return
                    }
                    guard let urlString = dict.value(forKey: "url") as? String else {
                        return
                    }
                    guard let url = URL(string: urlString) else { return }
                    let newPokemon = Pokemon(name: name, url: url)
                    thisPokemonList.append(newPokemon)
                }
                
                DispatchQueue.main.async {
                    completion(thisPokemonList, nextURL)
                }
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        dataTask.resume()
    }
}
