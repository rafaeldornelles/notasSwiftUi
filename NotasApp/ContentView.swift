//
//  ContentView.swift
//  NotasApp
//
//  Created by IOS SENAC on 9/4/21.
//

import SwiftUI


struct ContentView: View {
    @FetchRequest(entity: Nota.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Nota.data, ascending: true)]) var notas: FetchedResults<Nota>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notas, id: \.self) { nota in
                    NotaItem(nota: Binding.constant(nota))
                }.onDelete(perform: deleteItems)
            }.navigationBarTitle("Minhas Notas", displayMode: .inline)
            .navigationBarItems(trailing:
                NavigationLink(
                    destination: NotaForm(nota: nil)){
                    Text("Adicionar")
                        
                }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    private func deleteItems(at offset: IndexSet) {
        for index in offset{
            let nota = notas[index]
            PersistenceController.banco.delete(nota)
        }
    }
}

struct NotaItem: View {
    @Binding var nota: Nota
    var body: some View{
        HStack{
        NavigationLink(destination: NotaDetail(nota: nota)){
            HStack(){
                Text("\(nota.titulo ?? "--")")
                Spacer()
                if let dataNota = nota.data{
                    Text(dataNota, style: .date)
                        .font(.footnote)
                        .fontWeight(.light)
                        .foregroundColor(Color.gray)
                }
            }
        }
        }
    }
}

struct NotaDetail: View {
    var nota: Nota
    
    @State var isEdit = false
    
    var body: some View{
        VStack(alignment: .leading){
            if let dataCriacao = nota.data{
                Text("Criada em \(dataCriacao, style: .date)")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.leading)
            }
            Text(nota.conteudo ?? "")
                .multilineTextAlignment(.leading)
                    Spacer()
                    
        }.navigationBarTitle(nota.titulo ?? "-", displayMode: .large)
            .navigationBarItems(trailing: Button("Editar"){
                    self.isEdit = true
                })
            NavigationLink(
            destination: NotaForm(nota: nota),
                isActive: $isEdit){EmptyView()}
    
    }
}

struct NotaForm: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var nota: Nota?
    @State var titulo: String = ""
    @State var conteudo: String = ""
    
    init(nota: Nota?) {
        self.nota = nota
        self._titulo = State(wrappedValue: self.nota?.titulo ?? "" )
        self._conteudo = State(wrappedValue: self.nota?.conteudo ?? "")
    }
    
    var body: some View{
        VStack(alignment: .leading){
            Text("Título")
            TextField("Titulo", text: $titulo)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text("Conteúdo")
            TextEditor(text: $conteudo)
                .overlay(
                         RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                            .opacity(0.3)
                         )
            
        }.navigationBarTitle("Nova Nota")
        .navigationBarItems(trailing: Button("Salvar"){
            let notaEdit: Nota = self.nota ?? Nota(context: managedObjectContext)
            notaEdit.titulo = titulo
            notaEdit.conteudo = conteudo
            notaEdit.data = notaEdit.data ?? Date()
            
            
            PersistenceController.banco.save()
            self.presentationMode.wrappedValue.dismiss()
        }).padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        NotaDetail(nota: Nota())
        NotaForm(nota: nil)
    }
}
