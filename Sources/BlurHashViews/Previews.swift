//
//  Previews.swift
//  Xcode previews for blur hash views
//
//
//  Created by Dale Price on 6/13/24.
//

import SwiftUI

@available(iOS 18, tvOS 18, visionOS 2, macOS 15, watchOS 11, macCatalyst 13, *)
#Preview {
	@Previewable @State var punch: Float = 1
	@Previewable @State var smoothColors: Bool = true
	@Previewable @State var colorSpace: Gradient.ColorSpace = .perceptual
	
	/// Example blurHashes from images shared on various Fediverse services
	let hashes = [
		"UCQ9_@~q%M9F%MIUIU-;t7WB%MIU_3RjRjt7",
		"UVL3iAw4My%2F$IW#j%2Vz={spay}%s:ESxF",
		"UrNwf#tQxuW;XRxuR*of~qs;RPofspRkofae",
		"UGF=8e~VE4=_IdI]-nbd}i$zR*xuK,xvM{S5",
		"UV7-]RkBkBfkVUj[bIfPSSafV@f8RNafaejb",
		"UQD9hvi_9abbRikDxuWBE1RjkBsm4Tt7WUoz",
		"UDAv%*9tIo-;ENRPD%og?^Vs%1tRIBR*WBRj",
		"UUODXt4TNID$xuM{t6ofS1t5V@x]kXRkRjWC",
		"UMAJ{7xa4oIpV?ogogWV0KR%?axas-RjR*s:",
		"UKEee}0h4:%1xWM|-oxtIVxCx[WC~UaeE2WB",
		"UkRL|JofxukCT#R*j[t6xajZM{oLoct7oJRj",
		"UZDwdiNIMwozyZa$adofxvV?WCa}bbMwt8of",
		"UYI?4%j@WojsCTj]n%j@^Nn%a}fPRpWobHj[",
		"UbFOPuxZRls.~Bs.WCoeEmR-oIj[5DR-ocWV",
		"UXKSkg5UofxY^OWEI;oJ^hsDNHbF}:RnxGW:",
		"eqALq%WEVrkWbbt:eljEkDflRQjXo#aejtM}kXofaekDahkCaekDa~",
		"etCs~.x]ROjsa}%%o#RiWVf6x_ogj[ofaxbIaxozogaxRkRjofozay",
		"enE{qcRPn$t6WE%%V@NGbIof.9f5s,a#j[x^a#WVayazWsogj[oKj[",
		"e3FFpjnNIoogxtxtM{sSxvNH01x[-:-po#~p%2IpWCxsxuR*adNHs:",
		"eMDAfjngtStSo$W?ROV?obV?%%j[ROV@j?aJtTkDWBozRko#x^V@V?",
		"U,KKya%2ofjY?w%2WBRk-;kCWCofRjaxayj[",
		"UMD9#O%M4nWB00M{t7Rjj[ofj[ofxuofofj[",
		"UpEoo~slt7xZx|f6j=j[A3WCWBRkRof6a#ay",
		"UHBM[C~pD*IV?GxtNGWBIUM{WCofIURkxut7",
		"UqDKx~xuR+WB*0o0WDWVIVRjV@ofROs;ogj[",
		"UcDAyDxuWBoeN4ogayWBH;WVWAWB.9t7WBWB",
		"UcE.n[V{j=oM?wNGj[j[.7R.a}WUxvRls.oM",
		"U[KT}4IURjWF~pRPWAf8bdocj?jZRkoykBax",
		"UD9*fP~prAIAx]t6s.axn~j?bHfkfkayayjs",
		"UEDAsCETjr-o0URjoeNGVq-nt5M}%OM{ae%2",
		"UC5?rpt:ZyV@t3ogadayekade.j]adazflj[",
		"UA7BpCWTxtn+x|kDadj]R4ofs,WnZ}WBW;jF",
		"UwE449oxWAWByZocaxkB.8oMWXWBxsbYofj[",
		"UDG[sJnN?b%M=CW?oHof00RixaRiX:flbcW?",
		"UkAwoQo#ROt8.AogRiogx^oza#j[tTo#j]fP",
		"UuH.+gRiRjs:?KRjWBbHt7j^t7ofW9a}ofa}",
		"UUAnQQx^ROV@yGo#W9afD+kEt7bIMwRkfkkB",
		"U.IFV:kBWBjsyGxtayWBogs.aekCROWBoea}",
		"UgFib-Rkjqt6x|t6WBWE%it6ayWV%goLoLk9",
		"UxKbq0s:ofoL}GoLWpjt9ZayWCfQI.oJsofj",
		"UJCGDIE3xZR+~q9axtRkt7M|xtWBjFxuWEaz",
		"UiBzqwWCayj[x|f7ayfRICj?j@f7t4ayfjfQ",
		"UZGIr^WBogj]%%a#RjfQ?cf6t7juxuj[WBj[",
		"UM7n;9t8t6k8tBf,s.ocH;Wos.of%Moct7W?",
		"UID8;Q}^ABXLOkNZR-WB0K9Yob,uRRRRnkkn",
		"UBD,7e9a9EV?.AtTV=WAE8s+s*t84mM^fktS",
		"U9CGGE-=acbJtnxbM|j]9D9GRjM|4TM^s*M{",
		"ULHTL9]_|6}jK*ESI=jr+~s+J6Ne9uax$gj]",
		"UVNKFy00IUM{xu4nM{%MD%IUofxut7ayM{Rj",
		"UGDj^$|@M|xbOYRj#+xZ57K5S~EfMxXTKPaK",
		"UwMiN:3pK%%fs8OrXmkWM|bGOYnOxGa}a}X8",
		"UMEf_|S|Gt-:Iga1-VtR0fwb=dSg=CpHJ6aK",
		"UZED00R~aLr__LNrWBs;RjNZkBo|aLRjxakU",
		"UyI$+tR7w[xt*0jYr=kVJVxtjZRkNKNHWVkC",
		"UZJr^3w{dD#-]nWp;}w_VZJSt6WVJnNujZNv",
	]
	
	ScrollView {
		Grid {
			GridRow {
				Text("Average color")
				Text("Simple MeshGradient")
				Text("MeshGradient")
				Text("Palette")
			}
			.font(.caption)
			
			ForEach(hashes, id: \.self) { hash in
				GridRow {
					Color(averageFromBlurHash: hash)!
						.aspectRatio(1, contentMode: .fill)
					
					MeshGradient(
						fromBlurHash: hash,
						punch: punch,
						detail: .simple,
						smoothsColors: smoothColors,
						colorSpace: colorSpace
					)
					.aspectRatio(1, contentMode: .fill)
					
					let unchangedMesh = MeshGradient.Mesh(
						fromBlurHash: hash,
						punch: punch,
						detail: .unchanged
					)!
					MeshGradient(
						unchangedMesh,
						smoothsColors: smoothColors,
						colorSpace: colorSpace
					)
					.aspectRatio(1, contentMode: .fill)
					
					HStack(spacing: 0) {
						let palette = try! unchangedMesh.getPalette(count: 5, resolvingColorsIn: EnvironmentValues())
						ForEach(palette, id: \.self) { color in
							Rectangle()
								.fill(color)
						}
					}
				}
			}
		}
	}
	#if !os(watchOS) && !os(tvOS)
	.safeAreaInset(edge: .bottom) {
		Form {
			LabeledContent {
				Slider(value: $punch, in: 0...1)
			} label: {
				Text("Punch")
			}
			
			Toggle("Smooth Colors", isOn: $smoothColors)
			
			Picker("Gradient Color Space", selection: $colorSpace) {
				Text("Device")
					.tag(Gradient.ColorSpace.device)
				
				Text("Perceptual")
					.tag(Gradient.ColorSpace.perceptual)
			}
		}
		.frame(height: 200)
		.scrollContentBackground(.hidden)
		.background(.thinMaterial)
	}
	#endif
}

