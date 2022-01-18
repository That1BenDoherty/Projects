//
//  CustomTeamHeader.swift
//  SportsApp_finalproject
//
//  Created by Doherty, Benjamin J on 12/2/19.
//  Copyright © 2019 Doan, Douglas T. All rights reserved.
//

import UIKit
import CoreData

class CustomTeamHeader: UITableViewHeaderFooterView {
    
    // Set up for headers in our favorites view. Has a logo, team name, and delete button

    let title = UILabel()
    
    // Image view for logo, border make circle that logo sits in thats colored to teams color, back border is just white cirle behind border so that there is white behind the slightly transparent border
    let image = UIImageView()
    let border = UIView()
    let backBorder = UIView()
    
    // Creates delete button, rather than having a label we just have a trash can image and the word "Delete" displayed on top. Have cover that's same color as header so that button can slide from behind it, rathan slide from offscreen. Swipped var is to make sure you can't keep swiping make make the delete fly off screen
    let deleteButton = UIButton()
    let delete = UILabel()
    let deleteImage = UIImageView()
    let cover = UIView()
    var swiped = false

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    func configureContents() {
        image.translatesAutoresizingMaskIntoConstraints = false; title.translatesAutoresizingMaskIntoConstraints = false; border.translatesAutoresizingMaskIntoConstraints = false; backBorder.translatesAutoresizingMaskIntoConstraints = false; delete.translatesAutoresizingMaskIntoConstraints = false; deleteButton.translatesAutoresizingMaskIntoConstraints = false; deleteImage.translatesAutoresizingMaskIntoConstraints = false; cover.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(backBorder)
        contentView.addSubview(border)
        contentView.addSubview(image)
        contentView.addSubview(title)
        contentView.addSubview(deleteButton)
        contentView.addSubview(delete)
        contentView.addSubview(deleteImage)
        contentView.addSubview(cover)
        
        // Border set up, both white (until team color noted) and both circles
        border.backgroundColor = UIColor.white; backBorder.backgroundColor = UIColor.white
        border.layer.cornerRadius = 25; backBorder.layer.cornerRadius = 25
        
        title.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        deleteButton.backgroundColor = UIColor.red
        deleteButton.layer.cornerRadius = 3
        delete.text = "Delete"; delete.font = UIFont.systemFont(ofSize: CGFloat(13)); delete.textAlignment = .right
        deleteImage.image = UIImage(systemName: "trash")
        deleteImage.tintColor = UIColor.black
        deleteImage.isUserInteractionEnabled = false; delete.isUserInteractionEnabled = false; deleteButton.isUserInteractionEnabled = true // Don't want people to click on label, just button
        cover.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        NSLayoutConstraint.activate([
            // Center the logo and border vertically and place it near the leading edge of the view. Constrain its width and height to 50 points.
            image.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            image.widthAnchor.constraint(equalToConstant: 50),
            image.heightAnchor.constraint(equalToConstant: 50),
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            border.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            border.widthAnchor.constraint(equalToConstant: 50),
            border.heightAnchor.constraint(equalToConstant: 50),
            border.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            backBorder.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            backBorder.widthAnchor.constraint(equalToConstant: 50),
            backBorder.heightAnchor.constraint(equalToConstant: 50),
            backBorder.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Center the title vertically, and use it to fill the remaining space in the header view.
            title.heightAnchor.constraint(equalToConstant: 30),
            title.leadingAnchor.constraint(equalTo: image.trailingAnchor,
                       constant: 8),
            title.trailingAnchor.constraint(equalTo:
                       contentView.layoutMarginsGuide.trailingAnchor),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Delete button set just outside views margin
            deleteButton.leadingAnchor.constraint(equalTo:
            contentView.layoutMarginsGuide.trailingAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 70),
            deleteButton.heightAnchor.constraint(equalToConstant: 30),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            cover.leadingAnchor.constraint(equalTo:
            contentView.layoutMarginsGuide.trailingAnchor),
            cover.widthAnchor.constraint(equalToConstant: 70),
            cover.heightAnchor.constraint(equalToConstant: 30),
            cover.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Position delete buttons labels in the button
            deleteImage.leadingAnchor.constraint(equalTo: deleteButton.leadingAnchor,
            constant: 6),
            deleteImage.widthAnchor.constraint(equalToConstant: 13),
            deleteImage.heightAnchor.constraint(equalToConstant: 16),
            deleteImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            delete.trailingAnchor.constraint(equalTo: deleteButton.trailingAnchor,
            constant: -7),
            delete.widthAnchor.constraint(equalToConstant: 50),
            delete.heightAnchor.constraint(equalToConstant: 15),
            delete.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
