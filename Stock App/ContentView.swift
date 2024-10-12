import SwiftUI

struct ContentView: View {
    
    @State private var textInput = ""
    @State private var stockData: StockData? = nil
    @FocusState private var isFocused: Bool
    @State private var showError = false
    @State private var isNavigating = false
    
    init() {
    
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hue: 0.5417, saturation: 1, brightness: 0.1, alpha: 1.0)

        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hue: 0.5417, saturation: 1, brightness: 0.1)
                    .ignoresSafeArea()
                VStack {
                    Image("Stocky")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    Text("Enter stock symbol")
                        .foregroundColor(Color(.white))
                                .padding(.leading, 10)
                    TextField("", text: Binding(
                        get: {
                            textInput
                        },
                        set: {
                            textInput = $0.uppercased()
                        }
                    ))
                    .padding()
                    .background(Color(hue: 0.5417, saturation: 1, brightness: 0.07))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .padding() // Outer padding
                    .focused($isFocused)
                    
                    Button("Submit") {
                        fetchStockData(symbol: textInput)
                        textInput = ""
                        showError = false
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.white)
                    .padding()
                    
                    
                    if showError {
                        Text("Error fetching data. Please try again.")
                            .foregroundColor(.red)
                    }
                }
                .navigationTitle("Stock Search")
                .onAppear {
                    isFocused = true
                }
                // Use the `navigationDestination` modifier
                .navigationDestination(isPresented: $isNavigating) {
                    if let stock = stockData {
                        SecondView(stockData: stock)
                    } else {
                        Text("No stock data available.")
                    }
                }
            }
        }
    }
    
   
    func fetchStockData(symbol: String) {
        let apiKey = "LZ2CE9ID92TNGLYX"
        let urlString = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.showError = true
                }
                return
            }
            
            do {
                let stockResponse = try JSONDecoder().decode(StockResponse.self, from: data)
                DispatchQueue.main.async {
                    if let stock = stockResponse.globalQuote {
                        self.stockData = stock
                        self.isNavigating = true
                    } else {
                        self.showError = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError = true
                }
            }
        }.resume()
    }
}


struct StockResponse: Codable {
    let globalQuote: StockData?
    
    enum CodingKeys: String, CodingKey {
        case globalQuote = "Global Quote"
    }
}


struct StockData: Codable {
    let symbol: String
    let price: String
    let changePercent: String
    let open: String
    let highh: String
    let loww: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "01. symbol"
        case price = "05. price"
        case changePercent = "10. change percent"
        case open = "02. open"
        case highh = "03. high"
        case loww = "04. low"
    }
}


struct SecondView: View {
    
    
    var stockData: StockData
    
    var body: some View {
        ZStack {
            Color(hue: 0.5417, saturation: 1, brightness: 0.1)
                .ignoresSafeArea()
            VStack {
                Text("Stock Symbol: \(stockData.symbol)")
                    .font(.headline)
                    .padding(.bottom, 10)
                    .foregroundColor(Color(.white))
                
                Text("Price: $\(stockData.price)")
                    .font(.largeTitle)
                    .padding(.bottom, 10)
                    .foregroundColor(Color(.white))
                
                Text("Change: \(stockData.changePercent)")
                    .font(.subheadline)
                    .padding(.bottom, 10)
                    .foregroundColor(Color(.white))
                
                Text("Open Price: $\(stockData.open)")
                    .font(.subheadline)
                    .padding(.bottom, 10)
                    .foregroundColor(Color(.white))
                
                Text("Today's Low: $\(stockData.loww)")
                    .font(.subheadline)
                    .padding(.bottom, 10)
                    .foregroundColor(Color(.white))
                
                Text("Today's High: $\(stockData.highh)")
                    .font(.subheadline)
                    .padding(.bottom, 10)
                    .foregroundColor(Color(.white))
            }
            .navigationTitle("Stock Details")
            .padding(40)
            .background(Rectangle().foregroundColor(Color(hue: 0.5389, saturation: 1, brightness: 0.16)).cornerRadius(15))

        }
        .shadow(color: .black, radius: 15)
    }
}
    

#Preview {
    ContentView()
}
