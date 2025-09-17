package com.example.overlook_hotel.model;

import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrimaryKeyJoinColumn;
import jakarta.persistence.Table;
import java.util.HashSet;
import java.util.Set;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "managers")
@PrimaryKeyJoinColumn(name = "id")
@Getter
@Setter
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true, of = {})
@ToString(callSuper = true)
public class Manager extends Employee {

    private String department;

    private Integer accessLevel;

    @OneToMany(mappedBy = "manager")
    @ToString.Exclude
    private Set<Employee> team = new HashSet<>();

    @OneToMany(mappedBy = "manager")
    @ToString.Exclude
    private Set<Room> managedRooms = new HashSet<>();
}
