<br/>
<br/>


# NowMusic


<img width="200" alt="image" src="https://github.com/KimDaeSeong8721/TPOMusic/assets/69894461/03804b4f-9e94-4607-9350-f19df3a3afad">
  
<img width="200" alt="image" src="https://github.com/KimDaeSeong8721/TPOMusic/assets/69894461/adc27246-42f8-406b-a516-5cd22494fb65">


<br/>
<br/>
<br/>

### ✨ 프로젝트 소개 
**배경**
- 음악을 좋아하지만 그날의 상황에 따라 듣고 싶어하는 음악을 검색을 하는 시간과 에너지를 아끼고 싶었습니다.
<br>chatGPT의 출시가 이러한 문제를 해결해 줄 수 있다고 생각했습니다.

**한줄 소개**
- 특정한 시간, 장소, 상황에 어울리는 AI 노래 추천 및 플레이리스트 제작을 해주는 서비스입니다.

**기능**
1. TPO에 맞는 음악 검색
- 특정한 시간, 장소, 상황을 검색하면 AI가 추천하는 노래를 모아놓은 플레이리스트를 만들어줍니다.
2. TPO에 맞는 플레이리스트 제작
- 만들어진 플레이리스트를 클릭 한번으로 애플뮤직에서 바로 저장할 수 있습니다.
3. 스크린샷 저장 기능
- 추천 노래 목록들을 스크린샷하여 다른 음악 어플리케이션에서 음악들을 검색하는데 이용할 있습니다.
4. 히스토리
- 내가 검색했던 모든 TPO별 플레이리스트를 다시 찾아볼 수 있어요.
5. 음악 재생
- 애플 뮤직 구독자라면 노래 전체 듣기가, 아니라면 30초 미리 듣기가 가능합니다.
6. 한글, 영어 지원

<br/>
<br/>

### 📱 Screenshots

| TPO에 맞는 음악 검색 | TPO에 맞는 플레이리스트 제작 | 히스토리 | 음악 재생 |
|:---:|:---:|:---:|:---:|
|<img width="285" alt="image" src= "https://github.com/KimDaeSeong8721/TPOMusic/assets/69894461/5d9dcad2-dcf4-45bc-8b02-f00707316e8c"> |<img width="285" alt="image" src= "https://github.com/KimDaeSeong8721/TPOMusic/assets/69894461/906c988f-a064-400b-bbb2-d0daedc903b2"> |<img width="285" alt="image" src="https://github.com/KimDaeSeong8721/TPOMusic/assets/69894461/4e815ad6-3d4d-489e-9171-28c4c9f2ce10"> |<img width="285" alt="image" src="https://github.com/KimDaeSeong8721/TPOMusic/assets/69894461/cbaca9ef-6078-4169-8821-6d015f9dfd85">|

<br/>




### 🛠 Development Environment

<img width="77" alt="스크린샷 2021-11-19 오후 3 52 02" src="https://img.shields.io/badge/iOS-15.0+-silver"> <img width="95" alt="스크린샷 2021-11-19 오후 3 52 02" src="https://img.shields.io/badge/Xcode-15.0.1-blue">

<br/>

### :sparkles: Skills & Tech Stack

- UIKit
- MusicKit
- MVVM
- Combine
- CoreData
- ChatGPT API

<br/>

### 🎁 Library
| 라이브러리        | Version |       |
| ----------------- | :-----: | ----- |
| Kingfisher        | `7.0.0` | `SPM` |
| SnapKit           | `5.6.0` | `SPM` |
| Screenshots       | `1.0.0` | `SPM` |
| Lottie            | `3.5.0` | `SPM` |
  
<br/>

### 🧬 서비스 구조
<img width="800" alt="image" src="https://github.com/KimDaeSeong8721/TPOMusic/assets/69894461/0b170fb8-1449-4778-9688-1ccd3838603f">

<br/>
<br/>

### 🏛️ 아키텍쳐 구조
<img width="600" alt="image" src="https://github.com/KimDaeSeong8721/TPOMusic/assets/69894461/10cf39c0-8c70-4cf2-be3a-089fc1c65f4b">

<br/>

### :file_folder: Folder Structure
```
├── Global
│   ├── Base
│   │   └── BaseViewController.swift
│   ├── Extension
│   │   ├── NSObject+Extension.swift
│   │   ├── String+Extension.swift
│   │   ├── UICollectionView+Extension.swift
│   │   ├── UIColor+Extension.swift
│   │   ├── UIFont+Extension.swift
│   │   ├── UITableView+Extension.swift
│   │   ├── UIViewController+Alert.swift
│   │   ├── UIViewController+Extension.swift
│   │   └── URLSession+Extension.swift
│   ├── Literal
│   │   └── ImageLiteral.swift
│   ├── Managers
│   │   ├── CoreData
│   │   │   ├── Manager
│   │   │   │   ├── CoreDataManager.swift
│   │   │   │   └── MusicDataManager.swift
│   │   │   ├── MusicEntity+CoreDataClass.swift
│   │   │   ├── MusicEntity+CoreDataProperties.swift
│   │   │   ├── PlayListEntity+CoreDataClass.swift
│   │   │   ├── PlayListEntity+CoreDataProperties.swift
│   │   │   └── TPOMusic.xcdatamodeld
│   │   │       └── TPOMusic.xcdatamodel
│   │   │           └── contents
│   │   ├── Network
│   │   │   ├── EndPoint
│   │   │   │   └── SearchEndPoint.swift
│   │   │   └── Service
│   │   │       ├── APIEnvirionment.swift
│   │   │       ├── APIService.swift
│   │   │       ├── NetworkError.swift
│   │   │       └── NetworkRequest.swift
│   │   └── SoundManager.swift
│   ├── Protocol
│   │   └── ViewModelBindableType.swift
│   ├── Repository
│   │   └── SearchRepository.swift
│   ├── Resource
│   │   ├── Assets.xcassets
│   │   ├── Base.lproj
│   │   ├── Lottie
│   │   ├── en.lproj
│   │   └── ko.lproj
│   ├── Service
│   │   └── SearchService.swift
│   ├── Support
│   │   ├── AppDelegate.swift
│   │   └── SceneDelegate.swift
│   └── UIComponent
│       ├── BackButton.swift
│       ├── BackgroundView.swift
│       └── CustomDiffableDataSource.swift
├── Model
│   ├── ChatGPTResult.swift
│   ├── ChatMessage.swift
│   ├── Music.swift
│   └── PlayList.swift
├── Screen
│   ├── Home
│   │   ├── HistoryViewController.swift
│   │   ├── HomeViewController.swift
│   │   ├── SheetViewController.swift
│   │   ├── View
│   │   │   ├── Cell
│   │   │   │   └── HistoryCollectionViewCell.swift
│   │   │   └── CustomCollectionViewDiffableDataSource.swift
│   │   └── ViewModel
│   │       └── HistoryViewModel.swift
│   ├── Play
│   │   ├── PlayerViewController.swift
│   │   └── View
│   │       └── CustomSlider.swift
│   ├── PlayList
│   │   ├── PlayListViewController.swift
│   │   └── ViewModel
│   │       └── PlayListViewModel.swift
│   └── Search
│       ├── SearchResultViewController.swift
│       ├── View
│       │   ├── Cell
│       │   │   └── MusicTableViewCell.swift
│       │   └── SearchBarView.swift
│       └── ViewModel
│           ├── SearchResultViewModel.swift
│           └── SearchViewModel.swift
└── TPOMusic.entitlements
```
<br/>




### :people_hugging: Authors
[@Monica](https://github.com/monic98) | [@Miller](https://github.com/KimDaeSeong8721) |   [@Milli](https://github.com/jinccc97) | 
:---|:---|:---|
PM|Design|Design|Design
|<img width="150" src="https://user-images.githubusercontent.com/69894461/195982755-a2474974-3e7c-469a-8493-a9141eb39891.png">|<img width="150" src="https://user-images.githubusercontent.com/69894461/195982911-43b3aa8f-c846-4505-b2ba-f5903459127a.png">|<img width="150" src="https://user-images.githubusercontent.com/69894461/195982791-afbf0e36-6425-4500-b9d2-a07ca953d0c9.png">|

<br/>
<br/>

### :lock_with_ink_pen: License
MIT License

Copyright (c) 2023 NowMusic

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

<br/>
<br/>

